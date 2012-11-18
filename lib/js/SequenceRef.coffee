HTMLElement = require "HTMLElement"

class SequenceRef extends HTMLElement
  constructor: (args)->
    super args, (div)->
      div.append($("<div>").addClass("header")
                  .append($("<div>").addClass("tag")
                           .html "ref"))
         .append $("<div>").addClass "name"

SequenceRef::preferred_left_and_width = ->
    diag = @parents(".sequence-diagram:eq(0)")
    iact = @prevAll(".interaction:eq(0)")

    if iact.length is 0
        lines = $(".lifeline .line", diag)
        most = lines.mostLeftRight()
        most.width = most.width()
        return most

    objs = diag.find(".object")
    if objs.length is 0
        return {}
    if objs.length is 1
        it = objs.filter(":eq(0)")
        w = parseInt (@css("min-width") or @css("max-width") or @css("width"))
        l = it.offset().left - (w - it.outerWidth())/2
        if (dl = l - it.offset().left) < 0
          @css "margin-left":dl
          diag.css "margin-left":-dl
        return left:"auto"

    dh = diag.self()
             .find(".occurrence:eq(0)").width()
    occurs = iact.find(".occurrence")
    most = occurs.mostLeftRight()
    most.left -= dh
    most.width = most.width()
    most

core = require "core"
if core.env.is_node
  module.exports = SequenceRef
else
  core.exports SequenceRef
