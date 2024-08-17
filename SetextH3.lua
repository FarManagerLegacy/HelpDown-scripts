-- Make H3 headers out of H2 headings without id
-- Usefull for Setext-style H2 headers

--luacheck: globals Header
function Header (el)
  if el.identifier=="" and el.level==2 then
    el.level = 3
    return el
  end
end
