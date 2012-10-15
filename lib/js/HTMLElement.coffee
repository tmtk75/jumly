class HTMLElement
  constructor: (args, f)->
    cls = HTMLElement.to_css_name @constructor.name
    me = $.extend this, root = $("<div>").addClass cls
    f? me
    me.find(".name").text args
    me.data "_self", me

  @to_css_name: (s)->
    (if s.match /Diagram$/
      s.replace(/Diagram$/, "-Diagram")
    else
      s.replace(/^[A-Z][a-z]+/, ""))
    .toLowerCase()

core = require "core"
if core.env.is_node
  module.exports = HTMLElement
else
  core.exports HTMLElement
