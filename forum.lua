-- phpBB3 uses own markdown parser (https://s9etextformatter.readthedocs.io/Plugins/Litedown/Syntax/),
-- which differs in some minor details. That's why some fixes is need.

function Str (el)
  -- normal way of escaping the asterisk is \*, but that does not work in Litedown.
  if el.text=="*" then
    return pandoc.RawInline("markdown","[i]*[/i]")
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
