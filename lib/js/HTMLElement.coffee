$ = require "jquery"

_to_fname = (ctor)->
  if ctor.name
    return ctor.name
  a = (ctor + "").match(/function ([a-zA-Z_-]+)/)
  if a
    return a[1]
  console.error "cannot ensure class name", ctor

class HTMLElement
  constructor: (args, f)->
    cls = HTMLElement.to_css_name (_to_fname @constructor)
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
  @find("> *:eq(0)").outerWidth()  ## w/o margin

module.exports = HTMLElement
