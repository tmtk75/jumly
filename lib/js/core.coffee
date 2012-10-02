JUMLY = {}

_factories = (name, fact)-> _factories[name] = factory:fact

JUMLY.def = (name, type)-> _factories name, (_, opts)-> new type _, opts


jumly = (arg, opts) ->
  if (typeof arg is "object" && !arg.type)
    mapJqToJy = (arg) ->
      if (typeof arg is "object" && !(typeof arg.length is "number" && typeof arg.data is "function"))
        arg = $(arg)  # regard as a DOM node
      for i in [0..arg.length-1]
        a = $(arg[i]).self()
        arg[i] = if !a then null else a
      arg
    return mapJqToJy arg
  
  arg = $.extend({}, if typeof arg is "string" then {type:arg} else arg)
  meta = _factories[arg.type]
  throw "unknown type '" + arg.type + "'" if meta is undefined
  
  opts = $.extend arg, {name:null}, if typeof opts is "object" then opts else {name:opts}
  a = meta.factory opts
  a.find(".name:eq(0)").html(opts.name)
  a.name(opts.name) if opts.name
  a.attr id:opts.id if opts.id
  
  # Common methods
  a.gives = jumly.lang._gives(a, opts)
  a.data "uml:property", _self:a, type:arg.type, name: opts.name, stereotypes: -> []
  a

$ =
  fn: {}
$.jumly = jumly

$.fn.jprops = -> @data("uml:property")
$.fn.self = -> @jprops()?._self
$.fn.selfEach = (f)-> @each (i, e)->
  e = $(e).self()
  throw new Error("self() returned undefined.", e) unless e?
  f e
  this

##
prefs_ = {}
preferences_ = (a, b)->
  if !b and typeof a is "string"
    return prefs_[a]
  prefs_[a] = $.extend prefs_[a], b

jumly.preferences = preferences_

$.fn.name = (n)->
  return @jprops()?.name if arguments.length is 0 or n is undefined
  @find(".name:eq(0)").html n
  @jprops()?.name = n
  this
$.fn.stereotype = (n)->
  return @jprops()?.stereotype if arguments.length is 0 or n is undefined
  @find(".stereotype:eq(0)").html n
  @jprops()?.stereotype = n
  switch @jprops().type
    when ".interaction" then @find(".message:eq(0)").self().stereotype n
    when ".message" then @addClass n
  this

## v0.1.1a
JUMLY.Naming =
  toCSSClass: (s)->s.replace(/^JUMLY/, "").replace(/Diagram$/, "-Diagram").toLowerCase()


core = {}

core._to_id = (that)->
  return that.attr("id") if that.constructor is jQuery
  that.toLowerCase().replace /[^a-zA-Z0-9_]/g, "-"

core._to_ref = (s)->
  if s.match /^[0-9].*/
    '_' + s
  else
    s.replace(/^[0-9]|-/g, '_')

core.kindof = (that)->
  return 'Null' if that is null
  return 'Undefined' if that is undefined 
  ctor = that.constructor
  toName = (f)-> if 'name' in f then f.name else (''+f).replace(/^function\s+([^\(]*)[\S\s]+$/im, '$1')
  if typeof(ctor) is 'function' then toName(ctor) else tc # [object HTMLDocumentConstructor]
  
core._normalize = (that)->
  switch core.kindof that
    when "String" then return id:core._to_id(that), name:that
    when "Object" then ## Through down
    else
      if that and that.constructor is jQuery
        id = core._to_id(that)
        name = that.find(".name")
        if id? or (name.length > 0)
          return id:id, name: (if name.html() then name.html() else undefined)
        else
          return undefined
      console.error "Cannot recognize kind:", that
      throw new Error "Cannot recognize kind: '#{$.kindof that}'"
  keys = (p for p of that)
  return that if keys.length > 1

  id = keys[0]
  it = that[keys[0]]
  return {id:id, name:it} if $.kindof(it) is "String"

  keys = (p for p of it)
  return $.extend {}, it, {id:core._to_id(id), name:id} if keys.length > 1

  name = keys[0]
  mods = it[keys[0]]
  switch $.kindof(mods)
    when "Object" then $.extend {id:id, name:name}, mods
    when "Array", "Function"
      a = {id:core._to_id(id), name:id}
      a[name] = mods
      a

core.lang =
  _gives: (a, dic)->
    gives = (query)->
          r = dic[query]
          if r then r else null
    if !a.gives then return gives
    f = a.gives
    (query)->
      r = f(query)
      if r.length > 0 or r.of or r.as
          return r
      gives(query)
  _as: (m)-> as:(e)-> m[e]
  _of: (nodes, query)->
    (unode)->
      n = nodes.filter (i, e)->
        e = jumly(e)[0]
        s = e.gives(unode.jprops().type)
        if s is unode then e else null
      if n.length > 0 then jumly(n)[0] else []



class JUMLYError extends Error
  constructor: (@type, @message, @arguments, @cause, @jumlipt)->
    if typeof @type is "object"
      @type = p.type
      @message = p.message
      @arguments = p.arguments
JUMLY.Error = JUMLYError


class JUMLYPreferences
  @put = (a, b)-> JUMLYPreferences.values[a] = b
  @get = (a)->
    e = JUMLYPreferences.values[a]
    if typeof e is "function" then e() else e

JUMLY.Preferences = (a)->
  if typeof a is "string"
    JUMLYPreferences.get a
  else
    k = (e for e of a)[0]
    JUMLYPreferences.put k, a[k]

JUMLYPreferences.values =
  "document.id.validation.enable": false

core.env =
  is_node: (typeof module != 'undefined' and typeof module.exports != 'undefined')

JUMLY =
  env: core.env

if core.env.is_node
  global.JUMLY = JUMLY
  module.exports = core
else
  window.JUMLY = JUMLY

  exported = {}

  window.require = (name)->
    exported[name] or core

  core.exports = (func)->
    exported[func.name] = func
