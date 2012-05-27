#!/usr/bin/env coffee
fs = require "fs"
express = require "express"
assets = require "connect-assets"
jade = require "jade"
stylus = require 'stylus'
_ = require 'underscore'
yaml = require 'js-yaml'

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


lang_resources = yaml.load fs.readFileSync("views/tryjumly.i18n").toString()
args =
  VERSION: "0.1.2"
  markdown: (path)-> require("markdown-js").parse fs.readFileSync(path).toString()
  title: "JUMLY"
  layout: true
  i18n:
    _: (key)->
      a = lang_resources[key.toLowerCase()]
      if (a is undefined || a is null)
        return key
      if (a.ja)
        return a.ja
      a.en

app.get "/", (req, res)-> res.render 'index', args
app.get /tryjumly(;([a-z]+))/, (req, res)-> res.render "tryjumly", _.extend {}, args, title:"Try JUMLY", layout:false; console.log req.params
app.get /reference(;([a-z]+))/, (req, res)-> res.render "reference", title:"Reference"

port = 3000
if process.env.NODE_ENV is "heroku"
  console.log "run on heroku"
  port = process.env.PORT
app.listen port, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
