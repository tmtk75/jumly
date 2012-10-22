HTMLElement = require "HTMLElement"

class SequenceRef extends HTMLElement
  constructor: (args)->
    super args, (div)->
      div.append($("<div>").addClass("header")
                  .append($("<div>").addClass("tag")
                           .html "ref"))
         .append $("<div>").addClass "name"

# preferredWidth
SequenceRef::preferredWidth = ->
    diag = @parents(".sequence-diagram:eq(0)")
    iact = @prevAll(".interaction:eq(0)")

    if iact.length is 0
        lines = $(".lifeline .line", diag)
        most = lines.mostLeftRight()
        most.width = most.width()
        return most
   
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
