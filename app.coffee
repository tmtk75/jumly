#!/usr/bin/env coffee
fs = require "fs"
express = require "express"
assets = require "connect-assets"
jade = require "jade"
stylus = require('stylus')

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


app.get "/", (req, res)-> res.render 'index'
app.get "/reference", (req, res)-> res.render 'reference', body:require("markdown-js").parse fs.readFileSync("views/reference.md").toString()

app.listen 3000, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
