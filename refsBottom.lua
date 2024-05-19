--luacheck: globals meta Refs
local Label = meta.refsLabel
if not Label then -- default template of the links block
  local doc = pandoc.read[[
---
refsLabel: >

  - - -

  Другие разделы справки:\ 
...
]]
  Label = doc.meta.refsLabel
end

local function prepRefs (header) -- prepare refs section for current article
  local refs = Label:walk{} -- copy
  local inlines = refs[#refs].content
  --
  local links = Refs:filter(function (el) -- remove self from refs
    return el.target~=header.identifier
  end)
  local last = links[#links]
  for _,el in ipairs(links) do
    inlines:extend{pandoc.Str"[", el, pandoc.Str"]"}
    if el~=last then inlines:extend{pandoc.Str",", pandoc.Space()} end
  end
  return pandoc.Div(refs)
end

local function insertRefs (blocks, startIdx, endIdx)
  local header = blocks[startIdx]
  if header.identifier=="index" -- skip Index section
      or header.classes:includes("noref") then --e.g. cfgscript note
    return
  end
  local i = endIdx
  if blocks[i-1].tag=="Div" then -- insert ref block before div
    i = i-1
  end
  blocks:insert(i, prepRefs(header))
  return endIdx+1
end

return insertRefs
