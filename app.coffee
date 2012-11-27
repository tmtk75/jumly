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

version = fs.readFileSync("lib/version").toString().trim().split "\n"
params =
  VERSION     : version.join "-"
  VERSION_PATH: version[0]
  IMAGES_DIR  : "images"

index = (req, res)->
  res.render "index", (_.extend {}, params, lang:req.params[0] || "en")

app.get "/", index
app.get /\/index.([a-z]{2})$/, index

port = process.env.PORT || 3000
app.listen port
console.log "Listening at #{port}"
