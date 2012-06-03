has_window = (->
  try
    eval("window")
    true
  catch ex
    false)()
console.log "has_window:", has_window

if has_window
  console.log "running on browser"
  window.global = window
  window.require = (a)->
    console.log a
    if a.match(/jumly$/)
      JUMLY:JUMLY
else
  console.log "running on Node.js"

  global.CoffeeScript = require "coffee-script" 
  _ = require "underscore"
  require "node-jquery"
  require "#{__dirname}/jasmine-story"
  
  specs = require("fs").readdirSync(__dirname).filter (e)-> e.match ".*Spec.*"

  dir = "../../../../lib/jumly/js"
  require "#{dir}/jquery-ext"
  require "#{dir}/jquery-g2d"
  require "#{dir}/core"
  require "#{dir}/0.1.0"
  require "#{dir}/common"
  require "#{dir}/usecase"
  require "#{dir}/class"
  require "#{dir}/sequence"
  require "#{dir}/plugin"

  #exports.JUMLY = JUMLY
  #global.JUMLY = JUMLY
  console.log "Loaded successfully.", JUMLY

  _.each specs, (e)-> require "./#{e}"

