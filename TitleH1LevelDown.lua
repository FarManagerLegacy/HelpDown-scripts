-- Increment level by 1 for all the headers except main (#Contents)
-- Useful for Setext-style headers, where only 2 levels available.
-- To be used together with --shift-heading-level-by=1

--luacheck: globals Header
function Header (el)
  if el.identifier=="Contents" and el.level==1 then
    el.level = 0
    return el
  end
end
