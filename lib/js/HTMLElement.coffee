class HTMLElement
  constructor: ->
    cls = HTMLElement.to_css_name @constructor.name
    p = $.extend this, $("<div>").addClass cls
    #a = Array.prototype.slice.apply arguments
    #a.unshift p
    #@_build_?.apply this, a
    this

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
