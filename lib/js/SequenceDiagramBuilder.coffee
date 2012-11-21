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
  @_occurr = null
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
      @_diagram._var r, obj
    when "object"
      @_diagram._var core._to_ref(a.id), obj
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
      .find(".message").addClass(stereotype)

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
  else if typeof a is "object"
    e = core._normalize a
    actee = e.name
    async = a.asynchronous?
    callback = b if typeof b is "function"
  
  if typeof a is "string"
    id = core._to_id(actee)
  else
    norm = core._normalize a
    id = norm.id
    actee = norm.name

  iact = @_curr_occurr().create id:id, name:actee
  iact.name name if name
  iact.find(".message:eq(0)").addClass "asynchronous" if async
  occurr = iact._actee
  ctxt = new SequenceDiagramBuilder(@_diagram, occurr)
  callback?.apply ctxt, []
  @_var id, occurr._actor
  @_diagram._reg_by_ref id, occurr._actor
  ctxt

SequenceDiagramBuilder::_var = (varname, refobj)->
  ref = core._to_ref varname
  @_diagram._var ref, refobj

SequenceDiagramBuilder::destroy = (a) ->
  @_curr_occurr().destroy @_find_or_create a
  null

SequenceDiagramBuilder::reply = (a, b) ->
  obj = b
  if typeof b is "string"
    ref = core._to_ref core._to_id b
    obj = @_diagram[ref] if @_diagram[ref]

  f = (occur, n)-> if occur.is_on_another() then f(occur._parent_occurr(), n + 1) else n
  n = f @_curr_occurr(), 0
  @_curr_occurr()
    .parents(".interaction:eq(#{n})").data("_self")
    .reply name:a, ".actee":obj
  null

SequenceDiagramBuilder::ref = (a) ->
  SequenceRef = require "SequenceRef"
  occur = @_curr_occurr()
  ref = new SequenceRef a
  if occur
    occur.append ref
  else
    @diagram().append ref
  id = core._normalize(a).id
  @_diagram._reg_by_ref id, ref
  r = core._to_ref id
  @_diagram._var r, ref
  ref

SequenceDiagramBuilder::lost = (a) ->
  @_curr_occurr.lost()
  null

SequenceDiagramBuilder::loop = (a, b, c) ->
  last = [].slice.apply(arguments).pop()  ## Last one is Function
  if $.isFunction(last)
    kids = @_curr_occurr().find("> *")
    last.apply this, []
    newones = @_curr_occurr().find("> *").not(kids)
    if newones.length > 0
      SequenceFragment = require "SequenceFragment"
      frag = new SequenceFragment().addClass("loop").enclose newones
      frag.find(".name:first").html "Loop"
    if typeof a is "string"
      frag.find(".condition").html a
    frag
  

SequenceDiagramBuilder::alt = (ints) ->
  iacts = {}
  self = this
  for name of ints
    unless typeof ints[name] is "function"
      break
    
    _new_act = (name, act)-> ->  ## Double '->' is in order to bind name & act in this loop.
      nodes = []
      _ = (it)->
        if it?.constructor is SequenceDiagramBuilder
          node = it._curr_occurr().parent(".interaction:eq(0)")
        else
          node = it
        nodes.push node
      act.apply {
        _curr_actor: -> self._curr_actor.apply self, arguments
        message: -> _ (self.message.apply self, arguments)
        loop: -> _ (self.loop.apply self, arguments)
        ref: -> _ (self.ref.apply self, arguments)
      }
      nodes

    iacts[name] = _new_act name, ints[name]

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

SequenceDiagramBuilder::css = (styles) ->
  @_diagram.css styles

SequenceDiagramBuilder::find = (selector) ->
  @_diagram.find selector

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

