HTMLElement = require "HTMLElement.coffee"

class NoteElement extends HTMLElement
  constructor: (args, attrs)->
    super args, (me)->
      me.append($("<div>").addClass("name"))
    @css attrs.css if attrs

module.exports = NoteElement
