DiagramLayout = require "DiagramLayout"

class RobustnessDiagramLayout extends DiagramLayout

RobustnessDiagramLayout::_layout = ->
  elems = @diagram.find(".element")
  mlr = elems.mostLeftRight(true)
  mtb = elems.mostTopBottom(true)
  @diagram.width(mlr.width())
          .height(mtb.height())

core = require "core"
if core.env.is_node
  module.exports = RobustnessDiagramLayout
else
  core.exports RobustnessDiagramLayout
