fs = require "fs"
child_process = require "child_process"
tmp = require 'tmp'

_unlink = (path)->
  fs.unlink path, (err)->
    if err
      console.error "unlink: #{err}"
    #else
    #  console.log "unlink: #{path}"

_400_if_not_have = (res, str, vals)->
  unless str.toLowerCase() in vals
    res.status 400
    res.setHeader "content-type", "text/plain"
    res.write "unsupported media-type: #{str}"
    res.end()
    true

_senderr = (err, res, status = 500)->
  console.error err
  res.status status
  res.write JSON.stringify(err)
  res.end()

_diagrams = (is_post, jmcode, req, res)->
  tmp.file (err, tmp_path, tmp_fd)->
    return _senderr(err, res) if err

    fs.write tmp_fd, jmcode
    fs.close tmp_fd, (err)->
      if err
        _unlink tmp_path
        return _senderr(err, res)

      if is_post
        #req.headers["content-type"].match /(^[^\/]+)\/([^+]+)\+?(.*)$/
        [_, encoding, format, base64] = req.headers["accept"].match /(^[^\/]+)\/([^;]+)(;.*)?$/
        encoding = "base64" if base64 is ";base64" and encoding.match /image/i
        encoding = "html" if encoding.match(/^text$/i) and format.match(/^html$/i)
        format   = "png" if format is "*"
        encoding = "image" if encoding is "*"

        return if _400_if_not_have res, encoding, ["image", "base64", "html"]
        return if _400_if_not_have res, format, ["png", "gif", "jpg", "jpeg", "html"]
      else
        format = "png"
        encoding = "image"

      ## jumly prints tmpfile path to stdout if it creates image file
      filepath = ""
      if encoding.match /image/  ## jumly prints the filepath to stdout
        stdouth = (data)-> filepath += data
      else
        stdouth = (data)-> res.write data

      ## cmd path
      cmd = "#{__dirname}/../bin/jumly"
      console.log cmd, tmp_path, format, encoding

      ## exec jumly
      proc = child_process.spawn cmd, [tmp_path, format, encoding]
      proc.stdout.on 'data', stdouth
      proc.stderr.on 'data', (data)-> res.write data
      proc.on 'error', (err)-> console.error "error:", err

      proc.on 'close', (code)->
        console.log "close:", code
        if filepath
          fs.readFile filepath.trim(), flags:"rb", (err, data)->
            if err
              _senderr err, res, 400
            else
              res.write data
              res.end()
            _unlink tmp_path
            _unlink filepath.trim()
        else
          res.end()
          _unlink tmp_path

module.exports = (ctx)->
  b64decode: (req, res)->
    b64 = req.body.data.replace /^data:image\/png;base64,/, ""
    buf = new Buffer(b64, 'base64').toString 'binary'
    res.contentType "image/png"
    res.header "Content-Disposition", "attachment; filename=" + "diagram.png"
    res.status 201
    res.end buf, "binary"

  diagrams:
    get: (req, res)->
      res.setHeader "content-type", "image/png"
      #if req.query["data"].match /%/
      data = unescape req.query["data"]
      #else
      #  data = new Buffer(req.query["data"], 'base64').toString('ascii')
      _diagrams false, data, req, res

    post: (req, res)->
      _diagrams true, req.text, req, res
