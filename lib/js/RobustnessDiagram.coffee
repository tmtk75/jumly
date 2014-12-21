Diagram = require "Diagram.coffee"
IconElement = require "IconElement.coffee"

class RobustnessDiagram extends Diagram

core = require "core.coffee"

RobustnessDiagram::_node_of = (n, k)->
  id = core._to_id n
  ref = core._to_ref id
  return this[ref] if this[ref]

  e = new IconElement n, kind:k
  @_reg_by_ref id, e
  e


module.exports = RobustnessDiagram
