#!/usr/bin/env coffee
express = require "express"
jade    = require "jade"
assets  = require "connect-assets"
stylus  = require "stylus"
nib     = require "nib"
fs      = require "fs"
http    = require 'http'
domain  = require 'domain'

views_dir  = "#{__dirname}/views"
static_dir = "#{views_dir}/static"

app = express()
app.configure ->
  app.set 'port', (process.env.PORT || 3000)
  app.set "views", views_dir
  app.set "view engine", "jade"

  app.use express.bodyParser()
  app.use express.methodOverride()

  app.use express.cookieParser (secret = 'adf19dfe1a4bbdd949326870e3997d799b758b9b')
  app.use express.session secret:secret
  app.use express.logger 'dev'

  app.use (req, res, next)->
    if req.is 'text/*'
      req.text = ''
      req.setEncoding 'utf8'
      req.on 'data', (chunk)-> req.text += chunk
      req.on 'end', next
    else
      next()
 
  app.use stylus.middleware
    src: views_dir
    dest: static_dir
    compile: (str, path, fn)->
               stylus(str)
                 .set('filename', path)
                 .set('compress', true)
                 .use(nib()).import('nib')

  app.use assets src:"lib"

  app.use '/public', express.static "#{__dirname}/public"
  app.use '/',       express.static static_dir
  app.use app.router
  app.use express.favicon()

  app.use (req, res, next)->
    res.status 404
    res.render '404', req._parsedUrl


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
    jquery: "2.0.2"
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


http.createServer(app).listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"
