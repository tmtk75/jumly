$ = require "jquery"

class HTMLElement
  constructor: (args, f)->
    cls = HTMLElement.to_css_name @constructor.name
    me = $.extend this, root = $("<div>").addClass cls
    f? me
    me.find(".name").text args if args
    me.data "_self", me

  @to_css_name: (s)->
    (if s.match /Diagram$/
      s.replace(/Diagram$/, "-Diagram")
    else if s.match /NoteElement/
      s.replace(/Element$/, "")
    else
      s.replace(/^[A-Z][a-z]+/, ""))
    .toLowerCase()

HTMLElement::preferred_width = ->
  @find("> *:eq(0)").outerWidth()

module.exports = HTMLElement
