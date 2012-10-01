class DiagramBuilder

core = require "core"
if core.env.is_node
  CoffeeScript = require "coffee-script"
else
  CoffeeScript = window.CoffeeScript

DiagramBuilder::build = (script)->
  @diagram = @_new_diagram()
  (-> eval CoffeeScript.compile script).apply this, []
  @diagram

if core.env.is_node
  module.exports = DiagramBuilder
else
  core.exports DiagramBuilder
