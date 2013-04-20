self = require: JUMLY.require
Diagram = self.require "Diagram"
IconElement = self.require "IconElement"

class RobustnessDiagram extends Diagram

core = self.require "core"

RobustnessDiagram::_node_of = (n, k)->
  id = core._to_id n
  ref = core._to_ref id
  return this[ref] if this[ref]

  e = new IconElement n, kind:k
  @_reg_by_ref id, e
  e


if core.env.is_node
  module.exports = RobustnessDiagram
else
  core.exports RobustnessDiagram
