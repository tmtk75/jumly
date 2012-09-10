JUMLY = window.JUMLY

class JUMLYHTMLElement
  constructor: ->
    cls = JUMLY.Naming.toCSSClass @constructor.name
    p = $.extend this, $("<div>").addClass cls
    a = Array.prototype.slice.apply arguments
    a.unshift p
    @_build_?.apply this, a
    this

JUMLY.HTMLElement = JUMLYHTMLElement


