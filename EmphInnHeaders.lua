-- For hlf:
-- Enclose the content of inner headings in BlockQuote in order to add extra margin
-- and thus emphasize the header.

--luacheck: globals pandoc
local function BlockQuote (section)
  if section.classes[1]~="section" then return end
  local blocks = section.content
  local header = blocks[1]
  assert(header.tag=="Header")
  if section.identifier=="" then
    table.remove(blocks,1)
    return { header, pandoc.BlockQuote(blocks) }
  else
    header.identifier = section.identifier
    return blocks
  end
end

local function Pandoc (doc)
  doc.blocks = pandoc.structure.make_sections(doc.blocks)
  return doc
end

return {
  { Pandoc=Pandoc },
  { Div=BlockQuote },
}
