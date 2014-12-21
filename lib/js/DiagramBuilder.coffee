class DiagramBuilder

core = require "core.coffee"
#CoffeeScript = require "coffee-script"

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


module.exports = DiagramBuilder
