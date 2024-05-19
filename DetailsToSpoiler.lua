-- forum: replace <details> with bbcode [spoiler] tag
function RawBlock (el)
  if el.format=="html" then
    if el.text:match"</?details>" then
      -- todo <summary>
      return pandoc.RawBlock("markdown",el.text:gsub("<","["):gsub(">","]"):gsub("details","spoiler"))
    end
  end
end
