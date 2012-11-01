HTMLElement = require "HTMLElement"

jumly = $.jumly

## This is wrap feature keeping own instance, jQuery.wrap makes child node duplicated.
jQuery.fn.swallow = (_, f) ->
  f = f or jQuery.fn.append
  if _.length is 1
    if _.index() is 0 then _.parent().prepend this else @insertAfter _.prev()
  else
    #NOTE: In order to solve the case for object-lane. You use closure if you want flexibility.
    if _.index() is 0 then @prependTo $(_[0]).parent() else @insertBefore _[0]
  @append _.detach()
  this

Diagram = require "Diagram"

class SequenceDiagram extends Diagram
  constructor: ->
    super()

#JUMLY.def ".sequence-diagram", SequenceDiagram
    
SequenceDiagram::gives = (query)->
  e = @find(query)
  f = jumly.lang._of e, query
  {of: f}

prefs_ =
    WIDTH : null
    HEIGHT: 50

SequenceDiagram::$ = (sel) -> jumly($(sel, this))
SequenceDiagram::$0 = (typesel) -> @$(typesel)[0]
SequenceDiagram::preferences = (a, b) ->
    prefs = {}
    width = ->
        objs  = $(".object", this)
        left  = objs.min((e) -> $(e).position().left) - @position().left
        right = objs.max((e) -> $(e).position().left + $(e).outerWidth()) - @position().left
        left + (right - left) + left
    ## Return preferences
    if (!b and typeof a is "string") or (!a and !b)
        r = $.extend {}, prefs, prefs_
        r.WIDTH = width.apply this
        return r
    ## Overrite instance preferences
    #console.log "setter", prefs
    $.extend prefs, a


core = require "core"
if core.env.is_node
  module.exports = SequenceDiagram
else
  core.exports SequenceDiagram

