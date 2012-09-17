#!/usr/bin/env coffee
express = require "express"
jade = require "jade"
assets = require "connect-assets"
require "jumly-jade"

app = express()
app.set "view engine", "jade"
app.use express.static "#{__dirname}/views/static"
app.use assets src:"lib/jumly"

app.get "/", (req,res)->
  res.render "index"

app.listen port = 3000
console.log "Listening at #{port}"

###
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

conf =
  VERSION: fs.readFileSync("lib/jumly/version").toString()
  markdown: (path)-> require("markdown-js").parse fs.readFileSync(path).toString()
  title: "JUMLY"
  layout: true

i18n =
  value: (key, lang="en")->
    a = lang_resources[key.toLowerCase()]
    return key unless a
    a[lang] || key

app.get "/", (req, res)-> res.render 'index', conf
app.get /^\/([^;.]+)(;([a-z]+))?$/, (req, res)->
  mkparams = (req, opts)-> _.extend {}, conf, {i18n:_:(key)->i18n.value key, req.params[2]}, opts
  name = req.params[0]
  layouts =
    tryjumly :false
    spec     :false
    reference:true
    legacy   :false
  res.render name, mkparams req, layout:layouts[name]

port = 3000
if process.env.NODE_ENV is "heroku"
  console.log "run on heroku"
  port = process.env.PORT
app.listen port, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
###
