-- Remove <details> and <summary> tags
-- Useful for hlf, as HtmlToFarHelp does not support them
local REMOVE = {}
function RawBlock (el)
  if el.format=="html" then
    if el.text:match"^</?details>$" or el.text:match"^</?summary>$" then
      -- todo summary=>strong
      return REMOVE
    end
  end
end
