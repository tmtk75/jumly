#!/usr/bin/env coffee
express        = require "express"
jade           = require "jade"
assets         = require "connect-assets"
stylus         = require "stylus"
fs             = require "fs"
http           = require 'http'
domain         = require 'domain'
bodyParser     = require 'body-parser'
methodOverride = require 'method-override'
logger         = require "morgan"
cookieParser   = require "cookie-parser"
cookieSession  = require "cookie-session"
serveFavicon   = require "serve-favicon"
path           = require "path"
#session        = require 'express-session'
#MemoryStore    = require('express-session').MemoryStore
#log4js         = require "log4js"

views_dir  = path.join __dirname, 'views'
static_dir = path.join views_dir, 'static'

app = express()
app.set 'port', (process.env.PORT || 3000)
app.set "views", views_dir
app.set "view engine", "jade"
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true
app.use methodOverride()
#app.use express.query()
app.use cookieParser()
app.use cookieSession keys: ['adf19dfe1a4bbdd949326870e3997d799b758b9b']
app.use logger 'dev'
#app.use session store: new MemoryStore(reapInterval: 5 * 60 * 1000), secret: 'abracadabra', resave: true, saveUninitialized: true
app.use (req, res, next)->
  res.locals.session = req.session
  next()
app.use stylus.middleware
  src: views_dir
  dest: static_dir
app.use assets
  paths: [
    path.join __dirname, "lib/js"
    path.join __dirname, "lib/css"
  ]
app.use '/public', express.static "#{__dirname}/public"
app.use '/',       express.static static_dir
app.use (req, res, next)->
  if req.is 'text/*'
    req.text = ''
    req.setEncoding 'utf8'
    req.on 'data', (chunk)-> req.text += chunk
    req.on 'end', next
  else
    next()
#app.use serveFavicon()

require("underscore").extend jade.filters,
  code: (str, args)->
    type = args.type or "javascript"
    str = str.replace /\\n/g, '\n'
    js = str.replace(/\\/g, '\\\\').replace /\n/g, '\\n'
    """<pre class="brush: #{type}">#{js}</pre>"""
  jumly: (body, attrs)->
    type = attrs.type or "sequence"
    id = if attrs.id then "id=#{attrs.id}" else ""
    body = body.replace /\\n/g, '\n'
    js = body.replace(/\\/g, '\\\\').replace /\n/g, '\\n'
    """<script type="text/jumly+#{type}" #{id}>\\n#{js}</script>"""

pkg = JSON.parse fs.readFileSync("package.json")
ctx =
  version: pkg.version
  paths:
    release: "release"
    images: "public/images"
  tested_version:
    node: pkg.engines.node
    jquery: "2.1.0"
    coffeescript: pkg.dependencies["coffee-script"]


routes = require("./routes") ctx
api    = require("./routes/api") ctx

app.get "/",               routes.html "index"
app.get "/index.html",     routes.html "index"
app.get "/reference.html", routes.html "reference"
app.get "/api.html",       routes.html "api"
app.get "/try.html",       routes.html "try"
app.get "/api/diagrams",   api.diagrams.get
app.post "/api/diagrams",  api.diagrams.post

# redirect 302
app.get "/:path([a-z]+)", (req, res)-> res.redirect "/#{req.params.path}.html"

# 404
app.use (req, res, next)-> res.status(404).render '404', req._parsedUrl

# Start listening
http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"
