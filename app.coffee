#!/usr/bin/env coffee
fs = require "fs"
express = require "express"
assets = require "connect-assets"

app = module.exports = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static __dirname + "/public"
  conf = assets()
  conf.src = "#{__dirname}/lib/jumly"
  app.use conf

app.configure "development", -> app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure "production", -> app.use express.errorHandler()


app.get "/", (req, res)-> res.render 'index', title:'Express'

app.get /\/jumly\/(.*?).js/, (req, res)->
  coffee = require "coffee-script"
  res.contentType "text/javascript"
  buf = fs.readFileSync "#{__dirname}/lib/jumly/#{req.params[0]}.coffee"
  res.send coffee.compile buf.toString()

#app.get /\/(.*)\.js/, (req, res)-> res.send "#{__dirname}/#{req.params[0]}"

app.listen 3000, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
