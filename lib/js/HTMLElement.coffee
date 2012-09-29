class HTMLElement
  constructor: ->
    #cls = JUMLY.Naming.toCSSClass @constructor.name
    cls = @constructor.name
    p = $.extend this, $("<div>").addClass cls
    #a = Array.prototype.slice.apply arguments
    #a.unshift p
    #@_build_?.apply this, a
    this

core = require "core"
if core.env.is_node
  module.exports = HTMLElement
else
  core.exports HTMLElement
