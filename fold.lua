-- Save space moving all (except first) sections content inside spoilers
local function condition (header, blocks, idx)
  if pandoc.utils.stringify(header):match"cfgscript" then --hardcoded for now
    blocks[idx] = pandoc.HorizontalRule()
    return "skip"
  end
end

local function callback (blocks, startIdx, endIdx)
  -- transform headers into plain (but formatted) text
  blocks[startIdx] = pandoc.Para{pandoc.RawInline("markdown", "[u]"), pandoc.Strong(blocks[startIdx].content), pandoc.RawInline("markdown","[/u]")}
  blocks[startIdx].content:insert(pandoc.RawInline("markdown", " [spoiler]"))
  blocks:insert(endIdx, pandoc.RawBlock("markdown", "[/spoiler]"))
  return endIdx+1
end

local first = true
return {
  { -- remove redundant first header, as forum topic already has own title
    Header=function()
      if first then
        first = false
        return {}
      end
    end
  }, { -- add spoilers
    Pandoc=function(doc)
      require"sections"(doc.blocks, callback, condition)
      return doc
    end
  }
}
