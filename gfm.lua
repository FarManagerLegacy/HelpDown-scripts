--pandoc --list-extensions=gfm

function DefinitionList(el) --transform to BulletList
  local items = {}
  for i,item in ipairs(el.content) do
    local dt,blocks = table.unpack(item) --term,definitions
    local first = blocks[1]
    items[i] = first
    for j=2,#blocks do
      first:extend(blocks[j])
    end
    dt:extend{pandoc.Str"  "} --actually needed not for gfm but for some other flavors
    first:insert(1,pandoc.Plain(dt))
  end
  return pandoc.BulletList(items)
end

--todo Code to <kbd>:
--Code ( "" , [] , [] ) "Ctrl+Alt+Up"
--RawInline (Format "html") "<kbd>", Str "Ctrl+Alt+Up", RawInline (Format "html") "</kbd>"
