-- phpBB3 uses own markdown parser (https://s9etextformatter.readthedocs.io/Plugins/Litedown/Syntax/),
-- which differs in some minor details. That's why some fixes needed.

function Str (el)
  -- normal way of escaping the asterisk is \*, but that does not work in Litedown.
  if el.text:find"*" then
    if el.text=="*" then
      return pandoc.RawInline("markdown","[i]*[/i]") -- prevent parsing as list item
    end
    local parts,index,a,b = {},1
    repeat
      a,b,index = el.text:match("^([^*]*)%*([^*]*)()",index)
      table.insert(parts, pandoc.Str(a))
      table.insert(parts, pandoc.RawInline("markdown","*"))
      table.insert(parts, pandoc.Str(b))
    until index>el.text:len()
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
