-- phpBB3 uses own markdown parser (https://s9etextformatter.readthedocs.io/Plugins/Litedown/Syntax/),
-- which differs in some minor details. That's why some fixes needed.

local symbols = "([*><]+)"
function Str (el)
  -- normal way of escaping the asterisk is \*, but that does not work in Litedown.
  -- the same is with angle brackets
  if el.text:find(symbols) then
    if el.text=="*" then
      return pandoc.RawInline("markdown","[i]*[/i]") -- prevent parsing as list item
    end
    local parts,from = {},1
    repeat
      local a,b,after = el.text:match("^(.-)"..symbols.."()",from)
      if not a then
        table.insert(parts, pandoc.Str(el.text:sub(from)))
        break
      elseif a~="" then
        table.insert(parts, pandoc.Str(a))
      end
      table.insert(parts, pandoc.RawInline("markdown",b))
      from = after
    until from>el.text:len()
    return parts
  end
end

function Link (el)
  -- replace by Emph because forum engine fails to parse such links
  if el.target:match"^:" then
    return pandoc.Emph(el.content)
  end
  -- remove links as forum engine does not create anchors for headers.
  if el.target:match"^#" then
    return pandoc.Strong(el.content)
  end
end
