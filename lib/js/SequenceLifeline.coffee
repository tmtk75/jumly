self = require: JUMLY.require

HTMLElement = self.require "HTMLElement"

class SequenceLifeline extends HTMLElement
  constructor: (@_object)->
    self = this
    super null, (me)->
      me.append($("<div>").addClass "line")
        .width self._object.width()

core = self.require "core"
if core.env.is_node
  module.exports = SequenceLifeline
else
  core.exports SequenceLifeline
