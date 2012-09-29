HTMLElement = require "HTMLElement"

class Note extends HTMLElement

Note::_build_ = (div, a)->
  div.addClass("note")
     .append($("<div>").addClass("inner")
                       .append($("<div>").addClass("content").html a))

