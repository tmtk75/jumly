module.exports = (ctx)->
  index: (req, res)-> res.render "index", ctx
  reference: (req, res)-> res.render "reference", ctx
  api: (req, res)-> res.render "api", ctx
  try: (req, res)-> res.render "try", ctx
