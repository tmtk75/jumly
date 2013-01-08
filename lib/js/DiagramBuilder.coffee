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

DiagramBuilder::_refer = (pred)->
  id = core._normalize(a).id
  @_diagram._reg_by_ref id, ref
  r = core._to_ref id
  @_diagram._var r, ref


if core.env.is_node
  module.exports = DiagramBuilder
else
  core.exports DiagramBuilder
