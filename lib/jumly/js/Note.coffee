JUMLY = window.JUMLY
class JUMLYNote extends JUMLY.HTMLElement

JUMLYNote::_build_ = (div, a)->
  div.addClass("note")
    .append($("<div>").addClass("inner")
              .append($("<div>").addClass("content").html a))

JUMLY.def ".note", JUMLYNote
