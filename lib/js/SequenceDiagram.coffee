HTMLElement = require "HTMLElement"

class JUMLYFragment    extends HTMLElement
class JUMLYRef         extends HTMLElement
types = 
  ".fragment"        : JUMLYFragment
  ".ref"             : JUMLYRef
#JUMLY.def e, types[e] for e of types
jumly = $.jumly

JUMLYFragment::_build_ = (div)->
  div.append($("<div>").addClass("header")
                       .append($("<div>").addClass("name"))
                       .append($("<div>").addClass("condition")))

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

JUMLYFragment::enclose = (_) ->
    if not _? or _.length is 0
        throw "JUMLYFragment::enclose arguments are empty."
    if _.length > 1  # pre-condition: all nodes have same parent.
        a = $(_[0]).parent()[0]
        for i in [1 .. _.length - 1]
            b = $(_[i]).parent()[0]
            unless a is b
                throw {message:"different parent", nodes:[a, b]}
    if _.parent is undefined
        return this
    @swallow(_)
    this

JUMLYFragment::extendWidth = (opts) ->
    frag = this
    dlw = opts?.left
    drw = opts?.right
    dlw ?= 0
    drw ?= 0
    frag.css("position", "relative")
        .css("left", -dlw)
        .width(frag.width() + dlw/2)
        .find("> .interaction")
           .css("margin-left", dlw)
    frag.width(frag.outerWidth() + drw)

###
  opts: expected {"[condiaion-1]": <action>, "[condition-1]": <action}
###
JUMLYFragment::alter = (occurr, opts) ->
    alt = this
    alt.addClass("alt")
       .find(".condition").remove()  # because each interaction has each condition
    occurr.append alt
    for name of opts
        act = opts[name]
        unless typeof act is "function"
            throw "#{name} is not function"
        iact = act occurr  ## expect iact type is ".interaction"
        if iact is null or iact is undefined then break
        unless iact
            throw "#{iact} of #{name}'s action returned is not appendable into .alt.fragment"
        alt.append($("<div>").addClass("condition").html name)
           .append(iact)
           .append $("<div>").addClass("divider")
    alt.find(".divider:last").remove()
    alt

JUMLYRef::_build_ = (div)->
  div.append($("<div>").addClass("header")
                       .append($("<div>").addClass("tag")
                                         .html "ref"))
     .append $("<div>").addClass "name"

# preferredWidth
JUMLYRef::preferredWidth = ->
    diag = @parents(".sequence-diagram:eq(0)")
    iact = @prevAll(".interaction:eq(0)")

    if iact.length is 0
        lines = $(".lifeline .line", diag)
        most = lines.mostLeftRight()
        most.width = most.width()
        return most
   
    dh = diag.self()
            .find(".occurrence:eq(0)").width()
    occurs = iact.find(".occurrence")
    most = occurs.mostLeftRight()
    most.left -= dh
    most.width = most.width()
    most

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
    compose_most_left: 0
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

SequenceDiagram::compose = (props) ->
  try
    (new JUMLY.SequenceDiagramLayout).layout this
    this
  catch ex
    causemsg = switch ex.type
                 when "non_object_property_load" then "It may be not loaded completely for DOM tree.\n"
    console.error "JUMLY caught an exception: #{causemsg}", ex.stack, "\n", ex, {arguments:ex.arguments, stack:ex.stack, type:ex.type, message:ex.message, name:ex.name}
    throw ex

_css = (self, name)->
  a = self.css name
  return 0 unless a
  parseInt a

SequenceDiagram::preferredWidth = ()->
  bw = _css(this, "border-right-width") + _css(this, "border-left-width")
  nodes = $(".object, .ref, .fragment", this)
  return 0 + bw if nodes.length is 0
  a = nodes.mostLeftRight()
  return 0 + bw if a.left is a.right
  left = nodes.choose ((e)-> _css($(e), "left")), ((x, t)-> x < t)
  a.right - a.left + bw + 1


core = require "core"
if core.env.is_node
  module.exports = SequenceDiagram
else
  core.exports SequenceDiagram

