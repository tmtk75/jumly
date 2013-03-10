module.exports = (ctx)->
  en: (req, res)-> res.render "index", ctx
  ja: (req, res)-> res.render "index_ja", ctx
  reference: (req, res)-> res.render "reference", ctx
  try: (req, res)-> res.render "try", ctx
