exports.b64decode = (req, res) ->
  b64 = req.body.data.replace /^data:image\/png;base64,/, ""
  buf = new Buffer(b64, 'base64').toString 'binary'
  res.contentType "image/png"
  res.header "Content-Disposition", "attachment; filename=" + "diagram.png"
  res.status 201
  res.end buf, "binary"
