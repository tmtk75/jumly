core = require "core"

class HTMLElement
  constructor: ->
    #cls = JUMLY.Naming.toCSSClass @constructor.name
    cls = @constructor.name
    p = $.extend this, $("<div>").addClass cls
    #a = Array.prototype.slice.apply arguments
    #a.unshift p
    #@_build_?.apply this, a
    this

if typeof module != 'undefined' and module.exports
  module.exports = HTMLElement
else
  core.HTMLElement = HTMLElement
