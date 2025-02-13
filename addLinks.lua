-- Add links block
function Pandoc (doc)
  if doc.meta.links then
    table.insert(doc.blocks, pandoc.Para(doc.meta.links))
    return doc
  end
end
