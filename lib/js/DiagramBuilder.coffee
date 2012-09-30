class DiagramBuilder

DiagramBuilder::_accept = (f)->
  f.apply this, []

core = require "core"
if core.env.is_node
  CoffeeScript = require "coffee-script"
else
  CoffeeScript = window.CoffeeScript

DiagramBuilder::build = (script)->
  @diagram = @_new_diagram()
  @_accept -> eval CoffeeScript.compile script
  @diagram

if core.env.is_node
  module.exports = DiagramBuilder
else
  core.exports DiagramBuilder
