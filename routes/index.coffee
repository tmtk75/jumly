module.exports = (ctx)->
  html: (name)->
    (req, res)-> res.render name, ctx
