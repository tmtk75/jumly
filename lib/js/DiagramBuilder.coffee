self = require: JUMLY.require

class DiagramBuilder

core = self.require "core"
if core.env.is_node
  CoffeeScript = require "coffee-script"
else
  CoffeeScript = window.CoffeeScript

DiagramBuilder::build = (script)->
  (-> eval CoffeeScript.compile script).apply this, []
  @_diagram

DiagramBuilder::diagram = ->
  @_diagram

DiagramBuilder::_refer = (ref, adv)->
  id = core._normalize(adv.by).id
  @_diagram._reg_by_ref id, ref
  r = core._to_ref id
  @_diagram._var r, ref


if core.env.is_node
  module.exports = DiagramBuilder
else
  core.exports DiagramBuilder
