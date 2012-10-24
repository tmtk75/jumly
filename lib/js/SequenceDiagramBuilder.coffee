DiagramBuilder = require "DiagramBuilder"

class SequenceDiagramBuilder extends DiagramBuilder
  constructor: (@_diagram, @_occurr) ->
    super()
    @_diagram ?= new SequenceDiagram

SequenceDiagramBuilder::_curr_occurr = ->
  @_occurr

SequenceDiagramBuilder::_curr_actor = ->
  @_occurr._actor

SequenceDiagramBuilder::found = (sth, callback)->
  actor = @_find_or_create sth
  actor.addClass "found"
  @_occurr = actor.activate()
  callback?.apply this, [this]
  this

SequenceDiagram = require "SequenceDiagram"

core = require "core"
SequenceObject = require "SequenceObject"

SequenceDiagramBuilder::_find_or_create = (sth) ->
  a = core._normalize sth
  r = core._to_ref a.id
  return @_diagram[r] if @_diagram[r]
  obj = new SequenceObject sth
  @_diagram._reg_by_ref a.id, obj
  @_diagram.append obj
  switch typeof sth
    when "string"
      @_diagram._def r, obj
    when "object"
      @_diagram._def core._to_ref(a.id), obj
    else
      console.error "It must be string or object for", eth
      throw new Error "Unrecognized argument: #{e}"
  obj

SequenceDiagramBuilder::message = (a, b, c) ->
  actname  = a
  if typeof b is "function" or b is undefined
    actee = @_curr_actor()
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
      
  iact = @_curr_occurr().interact actee
  iact.find(".name").text(actname).end()
      .find(".stereotype").text(stereotype)

  it = (new SequenceDiagramBuilder @_diagram, iact._actee)
  callback?.apply it, []
  it

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
    id = core._to_id(actee)
  else
    norm = JUMLY.Identity.normalize a
    id = norm.id
    actee = norm.name
  iact = @_curr_occurr().create id:id, name:actee
  iact.name name if name 
  ## unless callback then return null  ##NOTE: In progress for this spec.
  occurr = iact._actee
  occurr._actor.attr("id", id).addClass "created-by"
  ctxt = new SequenceDiagramBuilder(diagram:@_diagram, _curr_occurr:occurr)
  callback?.apply ctxt, []
  @_def id, occurr._actor
  ctxt

SequenceDiagramBuilder::_def = (varname, refobj)->
  ref = core._to_ref varname
  @_diagram._def ref, refobj

SequenceDiagramBuilder::destroy = (a) ->
  @_curr_occurr().destroy @_find_or_create a
  null

SequenceDiagramBuilder::reply = (a, b) ->
  obj = b
  if typeof b is "string"
    ref = core._to_ref core._to_id b
    obj = @_diagram[ref] if @_diagram[ref]
  @_curr_occurr()
    .parents(".interaction:eq(0)").data("_self")
    .reply name:a, ".actee":obj
  null

SequenceDiagramBuilder::ref = (a) ->
  SequenceRef = require "SequenceRef"
  occur = @_curr_occurr()
  ref = new SequenceRef a
  if occur
    ref.insertAfter occur.parents(".interaction:eq(0)")
  else
    @diagram().append ref
  this

SequenceDiagramBuilder::lost = (a) ->
  @_curr_occurr.lost()
  null

## A kind of fragment
SequenceDiagramBuilder::loop = (a, b, c) ->
  ## NOTE: Should this return null in case of no context
  if a.constructor is this.constructor  ## First one is DSL
    frag = a._curr_occurr()
     .parents(".interaction:eq(0)").self()
     .fragment(name:"Loop")
     .addClass "loop"
  else
    last = [].slice.apply(arguments).pop()  ## Last one is Function
    if $.isFunction(last)
      kids = @_curr_occurr().find("> *")
      last.apply this, []
      newones = @_curr_occurr().find("> *").not(kids)
      if newones.length > 0
        SequenceFragment = require "SequenceFragment"
        frag = new SequenceFragment().addClass("loop").enclose newones
        frag.find(".name:first").html "Loop"
  this

## A kind of fragment
SequenceDiagramBuilder::alt = (ints) ->
  iacts = {}
  self = this
  for name of ints
    unless typeof ints[name] is "function"
      break
    act = ints[name]
    _new_act = (name, act) -> ->  ## Double '->' is in order to bind name & act in this loop.
      what = act.apply self
      unless what then return what
      what._curr_occurr()
          .parent(".interaction:eq(0)")
    iacts[name] = _new_act(name, act)
  @_curr_occurr().interact stereotype:".alt", iacts
  this

###
Examples:
  - @reactivate "do something", "A"
  - @reactivate @message "call a taxi", "Taxi agent"
###
SequenceDiagramBuilder::reactivate = (a, b, c) ->
  if a.constructor is this.constructor
    e = a._curr_occurr.parents(".interaction:eq(0)")
    @_curr_actor().activate().append e
    return a
  occurr = @_curr_actor().activate()
  @_occurr = occurr
  @message(a, b, c)

SequenceDiagramBuilder::_note = (a, b, c) ->
  nodes = @_curr_occurr.find("> .interaction:eq(0)")
  if nodes.length is 0
    nodes = @_curr_occurr.parents ".interaction:eq(0):not(.activated)"

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
    opts @_diagram
  else
    opts?.append @_diagram
  @_diagram.compose opts

SequenceDiagramBuilder::preferences = ->
  @_diagram.preferences.apply @_diagram, arguments

##
#JUMLY.DSL type:'.sequence-diagram', compileScript: (script) ->
#  b = new SequenceDiagramBuilder
#  b.build script.html()

#JUMLY.SequenceDiagramBuilder = SequenceDiagramBuilder

core = require "core"
if core.env.is_node
  module.exports = SequenceDiagramBuilder
else
  core.exports SequenceDiagramBuilder

