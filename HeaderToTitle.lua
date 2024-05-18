-- Grab first header as title, but only if no explicit metadata specified (yaml)

local title
function Header(el)
  if title then return end
  title = pandoc.utils.stringify(el)
end

function Meta(el)
  if not el.pagetitle then
    el.pagetitle = title
    return el
  end
end
