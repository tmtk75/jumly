#!/usr/bin/env coffee
fs = require "fs"
express = require "express"
assets = require "connect-assets"
jade = require "jade"
stylus = require 'stylus'
_ = require 'underscore'

jumly = (str, type)->
  str = str.replace /\\n/g, '\n'
  js = str.replace(/\\/g, '\\\\').replace /\n/g, '\\n'
  """<script type="text/jumly+#{type}">\\n#{js}</script>"""

jade.filters["jumly_sequence"] = (str)-> jumly str, "sequence"
jade.filters["jumly_class"]    = (str)-> jumly str, "class"
jade.filters["jumly_usecase"]  = (str)-> jumly str, "usecase"
jade.filters["code"]  = (str)->
  str = str.replace /\\n/g, '\n'
  js = str.replace(/\\/g, '\\\\').replace /\n/g, '\\n'
  """<pre class="brush: html">#{js}</pre>"""
  

app = module.exports = express.createServer()
app.configure ->
  #app.set 'view options', layout: false  ## off if you
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use stylus.middleware
    src:"#{__dirname}/views/stylesheets"
    dest:"#{__dirname}/public"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static __dirname + "/public"
  app.use assets src:"lib/jumly"
app.configure "development", -> app.use express.errorHandler dumpExceptions: true, showStack: true
app.configure "production", -> app.use express.errorHandler()


args =
  VERSION: "0.1.2"
  markdown: (path)-> require("markdown-js").parse fs.readFileSync(path).toString()
  title: "JUMLY"
get = (path, param)->
  a = path.replace /^\//, ""
  app.get path, (req, res)-> res.render a, _.extend args, param

app.get "/", (req, res)-> res.render 'index', args
get "/reference", title:"Reference"
get "/tryjumly", title:"Try JUMLY", layout:false

app.listen 3000, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
