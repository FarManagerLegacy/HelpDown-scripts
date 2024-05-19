-- Save space wrapping all (except first) sections content inside spoilers
-- Sections with header level > meta.foldLevel (when specified) will be absorbed

local function wrapSection (blocks, startIdx, endIdx)
  -- transform headers into plain (but formatted) text
  blocks[startIdx] = pandoc.Para {
    pandoc.RawInline("markdown", "[u]"),
    pandoc.Strong(blocks[startIdx].content),
    pandoc.RawInline("markdown","[/u]")
  }
  blocks[startIdx].content:insert(pandoc.RawInline("markdown", " [spoiler]"))
  blocks:insert(endIdx, pandoc.RawBlock("markdown", "[/spoiler]"))
  return endIdx+1
end

local first = true
return {
  {
    Header=function(el)
      if first then -- remove redundant first header, as forum topic already has own title
        first = false
        return {}
      end
      if el.classes:includes("noref") then --e.g. cfgscript note
        return pandoc.HorizontalRule()
      end
    end
  }, { -- add spoilers
    Pandoc=function(doc)
      local foldLevel = doc.meta.foldLevel
      foldLevel = foldLevel and tonumber(foldLevel[1].text)
      require"sections"(doc.blocks, wrapSection, function (header)
        if foldLevel and header.level>foldLevel then
          return "absorb"
        end
      end)
      return doc
    end
  }
}
