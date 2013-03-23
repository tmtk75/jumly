DiagramLayout = require "DiagramLayout"

class RobustnessDiagramLayout extends DiagramLayout

RobustnessDiagramLayout::_layout = ->
  elems = @diagram.find(".element")
  p = @diagram.offset()
  p.left += (parseInt @diagram.css "padding-left")*2
  p.top  += (parseInt @diagram.css "padding-top")*2
  elems.each (i, e)->
    $(e).css(position:"absolute")
        .offset
          left:p.left + (i % 3) * 120
          top:p.top + (i / 3) * 100

  mlr = elems.mostLeftRight(true)
  mtb = elems.mostTopBottom(true)
  @diagram.width(mlr.width())
          .height(mtb.height())

  @diagram.find(".relationship").each (i, e)-> $(e).data("_self").render()


core = require "core"
if core.env.is_node
  module.exports = RobustnessDiagramLayout
else
  core.exports RobustnessDiagramLayout
