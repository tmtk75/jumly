Diagram = require "Diagram"
IconElement = require "IconElement"

class RobustnessDiagram extends Diagram

core = require "core"

RobustnessDiagram::_node_of = (n, k)->
  id = core._to_id n
  ref = core._to_ref id
  return this[ref] if this[ref]

  e = new IconElement n, kind:k
  @_reg_by_ref id, e
  e

RobustnessDiagram::preferences = -> {}

if core.env.is_node
  module.exports = RobustnessDiagram
else
  core.exports RobustnessDiagram
