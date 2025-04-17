-- Add links block
function Pandoc (doc)
  local links = doc.meta.links
  if links then
    if links[1].t=="Str" or links[1].t=="Plain" or links[1].t=="Link" then
      links = {pandoc.Para(links)}
    end
    doc.blocks:insert(pandoc.HorizontalRule())
    doc.blocks:extend(links)
    return doc
  end
end
