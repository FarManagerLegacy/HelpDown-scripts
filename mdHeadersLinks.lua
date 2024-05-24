-- For md: as explicit attributes are not supported in gfm
-- we need to rewrite links to use implicit headers id's
-- https://github.com/jgm/pandoc/discussions/9794

-- unable to use gsub("%p" because string functions are not utf8-aware
local p = ".,:;?!/\\|<>()[]{}^°\"'#~´`=+*@$§&"
p = "["..p.."]"
local ids = {}
local function make_id (el)
  local title = pandoc.utils.stringify(el)
  local id = title:gsub(p,""):gsub(" ", "-")
  if ids[id] then
    local i,candidate = 0
    repeat
      i = i+1
      candidate = id.."-"..i
    until not ids[candidate]
    id = candidate
  end
  ids[id] = true
  return id
end

local headers = {}
local function Header (el)
  if el.identifier=="" then return end
  local id = make_id(el)
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
