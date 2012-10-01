DiagramBuilder = require "DiagramBuilder"

class SequenceDiagramBuilder extends DiagramBuilder
  constructor: (ctx) ->
    super()
    $.extend this, ctx

SequenceDiagramBuilder::found = (sth, callback)->
  actor = @_find_or_create sth
  actor.addClass "found"
  @_currOccurr = actor.activate()
  @last = callback?.apply this, [this]
  this

SequenceDiagram = require "SequenceDiagram"

SequenceDiagramBuilder::_new_diagram = ->
  new SequenceDiagram

core = require "core"
SequenceObject = require "SequenceObject"

SequenceDiagramBuilder::_find_or_create = (sth) ->
  a = core._normalize sth
  r = core._to_ref a.id
  return @diagram[r] if @diagram[r]
  obj = new SequenceObject a
  @diagram._reg_by_ref a.id, obj
  @diagram.append obj
  switch typeof sth
    when "string"
      @diagram._def r, obj
    when "object"
      @diagram._def JUMLY.Naming.toRef(a.id), obj
    else
      console.error "It must be string or object for", eth
      throw new Error "Unrecognized argument: #{e}"
  obj

SequenceDiagramBuilder::_actor = -> @_currOccurr.gives ".object"

SequenceDiagramBuilder::message = (a, b, c) ->
  actname  = a
  if typeof b is "function" or b is undefined
    actee = @_actor()
    callback = b
  else if typeof a is "string" and typeof b is "string"
    if typeof c is "function"
      actee = @_find_or_create b
      callback = c
    else if c is undefined
      actee = @_find_or_create b
      callback = null
  else if typeof a is "object" and typeof b is "string"
    actee = @_find_or_create b
    callback = c
    for e of a
      switch e
        when "asynchronous"
          actname = a[e]
          stereotype = "asynchronous" 
  else if typeof a is "string" and typeof b is "object"
    norm = JUMLY.Identity.normalize b
    actee = @_find_or_create norm
    callback = c
  else
    msg = "invalid arguments"
    console.error "SequenceDiagramBuilder::message", msg, a, b, c
    throw new Error(msg, a, b, c)
      
  iact = @_currOccurr.interact actee
  iact.name(actname)
      .stereotype(stereotype)
  ## unless callback then return null  ##NOTE: In progress for this spec.
  occurr = iact.gives ".actee"
  b = new SequenceDiagramBuilder(diagram:@diagram, _currOccurr:occurr)
  callback?.apply b, []
  b

SequenceDiagramBuilder::create = (a, b, c) ->
  if typeof a is "string" and typeof b is "function"
    name     = null
    actee    = a
    callback = b
  else if typeof a is "string" and typeof b is "string" and typeof c is "function"
    name     = a
    actee    = b
    callback = c
  else if typeof a is "string" and b is undefined
    name     = null
    actee    = a
    callback = null
  else if typeof a is "object" and typeof b is "function"
    e = JUMLY.Identity.normalize a
    actee    = e.name
    callback = b
  
  if typeof a is "string"
    id = JUMLY.Naming.toID(actee)
  else
    norm = JUMLY.Identity.normalize a
    id = norm.id
    actee = norm.name
  iact = @_currOccurr.create id:id, name:actee
  iact.name name if name 
  ## unless callback then return null  ##NOTE: In progress for this spec.
  occurr = iact.gives ".actee"
  occurr.gives(".object").attr("id", id).addClass "created-by"
  ctxt = new SequenceDiagramBuilder(diagram:@diagram, _currOccurr:occurr)
  callback?.apply ctxt, []
  @_def id, occurr.gives(".object")
  ctxt

SequenceDiagramBuilder::_def = (varname, refobj)->
  ref = JUMLY.Naming.toRef varname
  @diagram._def ref, refobj

SequenceDiagramBuilder::destroy = (a) ->
  @_currOccurr.destroy @_find_or_create a
  null

SequenceDiagramBuilder::reply = (a, b) ->
  obj = b
  if typeof b is "string"
    ref = JUMLY.Naming.toRef JUMLY.Naming.toID(b)
    obj = @diagram[ref] if @diagram[ref]
  @_currOccurr
    .parents(".interaction:eq(0)").self()
    .reply name:a, ".actee":obj
  null

SequenceDiagramBuilder::ref = (a) ->
  (jumly ".ref", a).insertAfter @_currOccurr.parents(".interaction:eq(0)")
  null

SequenceDiagramBuilder::lost = (a) ->
  @_currOccurr.lost()
  null

## A kind of fragment
SequenceDiagramBuilder::loop = (a, b, c) ->
  ## NOTE: Should this return null in case of no context
  if a.constructor is this.constructor  ## First one is DSL
    frag = a._currOccurr
     .parents(".interaction:eq(0)").self()
     .fragment(name:"Loop")
     .addClass "loop"
  else
    last = [].slice.apply(arguments).pop()  ## Last one is Function
    if $.isFunction(last)
      kids = @_currOccurr.find("> *")
      last.apply this, []
      newones = @_currOccurr.find("> *").not(kids)
      if newones.length > 0
        frag = jumly(".fragment").addClass("loop").enclose newones
        frag.find(".name:first").html "Loop"
  this

## A kind of fragment
SequenceDiagramBuilder::alt = (ints, b, c) ->
  iacts = {}
  self = this
  for name of ints
    unless typeof ints[name] is "function"
      break
    act = ints[name]
    _new_act = (name, act) -> ->  ## Double '->' is in order to bind name & act in this loop.
      what = act.apply self
      unless what then return what
      what._currOccurr
          .parent(".interaction:eq(0)")
    iacts[name] = _new_act(name, act)
  @_currOccurr.interact stereotype:".alt", iacts
  this

###
Examples:
  - @reactivate "do something", "A"
  - @reactivate @message "call a taxi", "Taxi agent"
###
SequenceDiagramBuilder::reactivate = (a, b, c) ->
  if a.constructor is this.constructor
    e = a._currOccurr.parents(".interaction:eq(0)")
    @_actor().activate().append e
    return a
  occurr = @_actor().activate()
  ctxt = new SequenceDiagramBuilder(diagram:@diagram, _currOccurr:occurr)
  ctxt.message(a, b, c)
  ctxt

SequenceDiagramBuilder::_note = (a, b, c) ->
  nodes = @_currOccurr.find("> .interaction:eq(0)")
  if nodes.length is 0
    nodes = @_currOccurr.parents ".interaction:eq(0):not(.activated)"

  ##TENTATIVE: because DSL notation is not decided.
  text = a
  opts = b
  note = jumly ".note", text
  if opts
    note.attach nodes, opts
  else
    nodes.append note

SequenceDiagramBuilder::compose = (opts) ->
  if typeof opts is "function"
    opts @diagram
  else
    opts?.append @diagram
  @diagram.compose opts

SequenceDiagramBuilder::preferences = ->
  @diagram.preferences.apply @diagram, arguments

##
#JUMLY.DSL type:'.sequence-diagram', compileScript: (script) ->
#  b = new SequenceDiagramBuilder
#  b.build script.html()

#JUMLY.SequenceDiagramBuilder = SequenceDiagramBuilder

##
# This is wrap feature keeping own instance, jQuery.wrap makes child node duplicated.
jQuery.fn.swallow = (_, f) ->
  f = f or jQuery.fn.append
  if _.length is 1
    if _.index() is 0 then _.parent().prepend this else @insertAfter _.prev()
  else
    #NOTE: In order to solve the case for object-lane. You use closure if you want flexibility.
    if _.index() is 0 then @prependTo $(_[0]).parent() else @insertBefore _[0]
  @append _.detach()
  this

core = require "core"
if core.env.is_node
  module.exports = SequenceDiagramBuilder
else
  core.exports SequenceDiagramBuilder

