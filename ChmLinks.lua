-- Make links to chm possible (in hlf)
function Link(el)
  if el.target:match("^mk:@MSITStore:") then
    el.target = "start hh "..el.target
    return el
  end
end
