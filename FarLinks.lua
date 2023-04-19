-- Make links to Far own help more useful (in md, html)
function Link(el)
  if el.target:match("^:%w+") then
    el.target = "hlf"..el.target
    if el.title=="" then
      el.title = "See Far help, "..el.target
    end
    return el
  end
end
