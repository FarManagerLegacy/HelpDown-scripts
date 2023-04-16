function Link(el)
  if el.target:match("^:%w+") then
    local repl = "hlf"..el.target
    el.target = repl
    if el.title=="" then
      el.title = ("See Far help, %s"):format(repl,repl)
    end
    return el
  end
end

function Header(el)
  el.level = el.level + 1
  return el
end
