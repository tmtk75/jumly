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
  window.exports = global
  window.require = (a)-> console.log "require", a, "ignored"
else
  console.log "running on Node.js"

  coffee = require "coffee-script" 
  require "node-jquery"
  require "./jasmine-story"

  dir = "../../../../lib/jumly/js"
  require "#{dir}/jquery-ext"
  require "#{dir}/jquery-g2d"
  core = (require "#{dir}/core.coffee")
  require "#{dir}/0.1.0"
  require "#{dir}/common"
  require "#{dir}/usecase"
  require "#{dir}/class"
  require "#{dir}/sequence"
  require "#{dir}/plugin"

  console.log "Load successfully."
  
  global.CoffeeScript = coffee
  global.JUMLY = core.JUMLY

  specs = require("fs").readdirSync(__dirname).filter (e)-> e.match ".*Spec.*"
  (require "underscore").each specs, (e)-> require "./#{e}"
