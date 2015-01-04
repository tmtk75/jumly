HTMLElement = require "HTMLElement.coffee"

class SequenceLifeline extends HTMLElement
  constructor: (@_object)->
    self = this
    super null, (me)->
      me.append($("<div>").addClass "line")
        .width self._object.width()

module.exports = SequenceLifeline
