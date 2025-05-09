-- Make H3 headers out of H2 headings without id
-- Useful for Setext-style H2 headers

--luacheck: globals Header
local parent
function Header (el)
  if el.identifier=="" then
    if el.level==2 and parent==2 then
      el.level = 3
      return el
    end
  else
    parent = el.level
  end
end
