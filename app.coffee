#!/usr/bin/env coffee
express = require "express"
jade    = require "jade"
assets  = require "connect-assets"
stylus  = require "stylus"
nib     = require "nib"
fs      = require "fs"
#routes  = require './routes'
#user    = require './routes/user'
http    = require 'http'
path    = require 'path'
require "jumly-jade"
(require "jade-filters").setup jade

app = express()
app.configure ->
  app.set 'port', (process.env.PORT || 3000)
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use stylus.middleware
    src: path.join __dirname, 'views'
    dest: path.join __dirname, 'views/static'
    compile: (str, path, fn)->
               stylus(str)
                 .set('filename', path)
                 .set('compress', true)
                 .use(nib())
                 .import('nib')

  app.use express.methodOverride()
  app.use express.cookieParser 'your secret here'
  app.use express.session()
  app.use express.static path.join __dirname, "views/static"
  app.use assets src:"lib"
  app.use express.bodyParser()

app.configure "development", ->
  app.use express.errorHandler()

version = fs.readFileSync("lib/version").toString().trim().split "\n"
params =
  VERSION     : version.join "-"
  VERSION_PATH: version[0]
  IMAGES_DIR  : "images"

images = require "./routes/images"
app.get "/", index_en = (req, res)-> res.render "index", params
app.get "/index", index_en
app.get "/index.en", index_en
app.get "/index.ja", (req, res)-> res.render "index_ja", params
app.get "/reference", (req, res)-> res.render "reference", params
app.get "/try", (req, res)-> res.render "try", params
app.post "/images", images.b64decode

http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"
