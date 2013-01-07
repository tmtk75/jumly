#!/usr/bin/env coffee
ctx = (require "express-jade-stylus").context
app = ctx.app

fs      = require "fs"
http    = require 'http'
require "jumly-jade"
images = require "./routes/images"

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
app.post "/images", images.b64decode

ctx.listen ->
  console.log "Express server listening on port #{app.get 'port'}"
