-- helper script to execute same `callback` function for every section
-- to the same section belong blocks beginning by header and ending by last block before next header
-- it is possible to skip some header (= absorb it's content into current section),
-- with `condition` function, returning `true`

return function (blocks, callback, condition)
  local start
  local i = 1
  repeat
    local el = blocks[i]
    if el.tag=="Header" then
      local skip = condition and condition(el, blocks, i)
      if not skip then
        if start then
          i = callback(blocks, start, i) or i
          assert(blocks[i]==el,"wrong index returned by callback")
        end
        start = i
      end
    end
    i = i+1
  until not blocks[i]
  if start then
    callback(blocks, start, i)
  end
end
