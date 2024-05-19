-- For hlf:
-- Make index page (out of pandoc-generated toc)
-- Add refs-block ("other help sections") to each article.

-- requires: meta.refsTemplate and --toc
-- optional: meta.refsLevel

--luacheck: globals Refs meta 
local function Pandoc (doc)
  meta = doc.meta
  if not meta.refsTemplate then
    --print("addRefs: no refsTemplate, exiting")
    return
  end
  local insertRefs = require(meta.refsTemplate[1].text)
  if not insertRefs then
    return
  end
  -- add Index section
  local toc = pandoc.structure.table_of_contents(doc.blocks):walk{Link=function(el)
    el.attr = pandoc.Attr() -- remove auto-id's "toc-title"
    return el
  end}
  doc.blocks:insert(pandoc.Header(1, "Index", pandoc.Attr("index", nil, {refsTitle="i"})))
  doc.blocks:insert(toc)
  --
  Refs = pandoc.List{} -- list of linked articles
  local refsLevel = meta.refsLevel
  refsLevel = not refsLevel and 1 or refsLevel[1] and tonumber(refsLevel[1].text)
  doc.blocks:walk { -- for refs pick all Headers with level<=meta.refsLevel (default 1)
    Header=function(el)
      if el.identifier~="" and not el.classes:includes("noref") then
        if refsLevel and refsLevel<el.level then return end
        local content, title = el.content
        if el.attributes.refsTitle then
          title = pandoc.utils.stringify(content)
          content = el.attributes.refsTitle
        end
        Refs:insert(pandoc.Link(content, el.identifier, title))
      end
    end
  }
  --
  require"sections"(doc.blocks, insertRefs)
  return doc
end

return {
  { Pandoc=Pandoc },
  { Div=function(el) return el.content end }, -- HtmlToFarHelp does not support Divs
}
