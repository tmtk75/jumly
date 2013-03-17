module.exports = (ctx)->
  index: (req, res)-> res.render "index", ctx
  reference: (req, res)-> res.render "reference", ctx
  try: (req, res)-> res.render "try", ctx
