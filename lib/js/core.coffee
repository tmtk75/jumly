$ = require "jquery"
jQuery = $
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
      throw new Error "Cannot recognize kind: '#{core.kindof that}'"
  keys = (p for p of that)
  return that if keys.length > 1

  id = keys[0]
  it = that[keys[0]]
  return {id:id, name:it} if core.kindof(it) is "String"

  keys = (p for p of it)
  return $.extend {}, it, {id:core._to_id(id), name:id} if keys.length > 1

  name = keys[0]
  mods = it[keys[0]]
  switch core.kindof(mods)
    when "Object" then $.extend {id:id, name:name}, mods
    when "Array", "Function"
      a = {id:core._to_id(id), name:id}
      a[name] = mods
      a

core.env =
  is_node: (typeof module != 'undefined' and typeof module.exports != 'undefined')

JUMLY =
  env: core.env

self = {}

if core.env.is_node
  global.JUMLY = JUMLY
  module.exports = core
else
  window.JUMLY = JUMLY

  exported =
    core: core
    "node-jquery": {}  ## suppress warning for "node-jquery"
    "./jasmine-matchers": {}  ## suppress warning for "./

  JUMLY.require = (name)->
    if name is undefined or name is null
      throw new Error "#{name} was not properly given"
    console.warn "not found:", name unless exported[name]
    exported[name]
  
  self.require = JUMLY.require

# Listen for window load, both in browsers and in IE.
unless core.env.is_node
  $(window).on 'DOMContentLoaded', ->
    JUMLY.scan()
