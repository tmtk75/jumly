class DiagramBuilder

core = require "core"
if core.env.is_node
  CoffeeScript = require "coffee-script"
else
  CoffeeScript = window.CoffeeScript

DiagramBuilder::build = (script)->
  (-> eval CoffeeScript.compile script).apply this, []
  @_diagram

DiagramBuilder::diagram = ->
  @_diagram

if core.env.is_node
  module.exports = DiagramBuilder
else
  core.exports DiagramBuilder
