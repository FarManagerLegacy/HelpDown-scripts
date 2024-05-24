-- For md: as explicit attributes are not supported in gfm
-- we need to rewrite links to use implicit headers id's
-- https://github.com/jgm/pandoc/discussions/9794

-- adapted from https://stackoverflow.com/a/72600888/2520247
local temp_doc = pandoc.Pandoc{}
local function make_id (el, via)
  local via = via or "html"
  table.insert(temp_doc.blocks, pandoc.Header(1, el.content))
  local roundtripped_doc = pandoc.read(pandoc.write(temp_doc, via), via)
  local blocks = roundtripped_doc.blocks
  return blocks[#blocks].identifier
end

local headers = {}
local function Header (el)
  if el.identifier=="" then return end
  local id = make_id(el, "gfm")
  if id~=el.identifier then
    headers["#"..el.identifier] = "#"..id
  end
end

local function Link (el)
  local match = headers[el.target]
  if match then
    el.target = match
    return el
  end
end

return {
  { Header=Header },
  { Link=Link },
}
