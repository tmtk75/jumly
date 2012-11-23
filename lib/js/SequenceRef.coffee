HTMLElement = require "HTMLElement"

class SequenceRef extends HTMLElement
  constructor: (args)->
    super args, (div)->
      div.append($("<div>").addClass("header")
                  .append($("<div>").addClass("tag")
                           .html "ref"))
         .append $("<div>").addClass "name"

SequenceRef::preferred_left_and_width = ->
  occurr = @parents(".occurrence:eq(0)")
  if occurr.length is 1
    w = occurr.outerWidth()
    right = occurr.offset().left + w
    return left:right - w/2

  ## NOTE: forllowing is not optimized and a bit adhoc.
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

  if (alt = @parents(".alt:eq(0)")).length is 1
    left = alt.parents(".occurrence")
    l = left.offset().left + left.outerWidth() - 1
    r = @parent().find(".occurrence").max (e)-> $(e).offset().left + $(e).outerWidth()/2
    d = left.outerWidth()/2 - 1
    return left:l - d, width:(r - l)

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
