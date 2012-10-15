HTMLElement = require "HTMLElement"

class SequenceLifeline extends HTMLElement
  constructor: (obj)->
    super null, (me)->
      me.append($("<div>").addClass("line").height(128))
        .width(obj.width())
        .height(128)

core = require "core"
if core.env.is_node
  module.exports = SequenceLifeline
else
  core.exports SequenceLifeline
