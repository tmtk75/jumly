#!/usr/bin/env coffee
_ = require "underscore"
express = require "express"
jade = require "jade"
assets = require "connect-assets"
stylus = require "stylus"
nib = require "nib"
fs = require "fs"
require "jumly-jade"
(require "jade-filters").setup jade

app = express()
app.set "view engine", "jade"
app.use stylus.middleware {
  src: __dirname + '/views'
  dest: __dirname + '/views/static'
  compile: (str, path, fn)->
             stylus(str)
               .set('filename', path)
               .set('compress', true)
               .use(nib())
               .import('nib')
}

app.use express.static "#{__dirname}/views/static"
app.use assets src:"lib"
app.use express.bodyParser()

version = fs.readFileSync("lib/version").toString().trim().split "\n"
params =
  VERSION     : version.join "-"
  VERSION_PATH: version[0]
  IMAGES_DIR  : "images"

app.get "/", index_en = (req, res)-> res.render "index", params
app.get "/index", index_en
app.get "/index.en", index_en
app.get "/index.ja", (req, res)-> res.render "index_ja", params
app.get "/reference", (req, res)-> res.render "reference", params
app.get "/try", (req, res)-> res.render "try", params
app.post "/images", (req, res) ->
  b64 = req.body.data.replace /^data:image\/png;base64,/, ""
  buf = new Buffer(b64, 'base64').toString 'binary'
  res.end buf, "binary"

port = process.env.PORT || 3000
app.listen port
console.log "Listening at #{port}"
