jumly = (arg, opts) ->
  mapJqToJy = (arg) ->
    if (typeof arg is "object" && !(typeof arg.length is "number" && typeof arg.data is "function"))
      arg = $(arg)  # regard as a DOM node
    for i in [0..arg.length-1]
      a = $(arg[i]).self()
      arg[i] = if !a then null else a
    arg
  mapJqToJy arg

$.jumly = jumly

##
$.fn.stereotype = (n)-> this

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

core.env =
  is_node: (typeof module != 'undefined' and typeof module.exports != 'undefined')

JUMLY =
  env: core.env

if core.env.is_node
  global.JUMLY = JUMLY
  module.exports = core
else
  window.JUMLY = JUMLY

  exported =
    core: core
    "node-jquery": {}  ## suppress warning for "node-jquery"
    "./jasmine-matchers": {}  ## suppress warning for "./

  window.require = (name)->
    if name is undefined or name is null
      throw new Error "#{name} was not properly given"
    console.warn "not found:", name unless exported[name]
    exported[name]

  core.exports = (func, name)->
    exported[func.name or name] = func


SCRIPT_TYPE_PATTERN = /text\/jumly-(.*)-diagram|text\/jumly\+(.*)|application\/jumly\+(.*)/

_to_type_string = (type)->
  unless type.match SCRIPT_TYPE_PATTERN then throw "Illegal type: #{type}"
  kind = RegExp.$1 + RegExp.$2 + RegExp.$3

_evalHTMLScriptElement = (script) ->
  script = $ script
  type = script.attr("type")
  throw "Not found: type attribute in script" unless type
  
  kind = _to_type_string type
  compiler = _compilers[".#{kind}-diagram"]
  layout = _layouts[".#{kind}-diagram"]

  throw "Not found: compiler for '.#{kind}'" unless compiler
  throw "Not found: layout for '.#{kind}'" unless layout

  diag = compiler script
  diag.insertAfter script
  layout diag

_compilers =
  '.sequence-diagram': (script)->
      Builder = require "SequenceDiagramBuilder"
      (new Builder).build script.html()

_layouts =
  '.sequence-diagram': (diagram)->
      Layout = require "SequenceDiagramLayout"
      (new Layout).layout diagram

_runScripts = ->
  return null if _runScripts.done
  scripts = document.getElementsByTagName 'script'
  diagrams = (s for s in scripts when s.type.match /text\/jumly+(.*)/)
  for script in diagrams
    _evalHTMLScriptElement script
  _runScripts.done = true
  null

# Listen for window load, both in browsers and in IE.
if window.addEventListener
  window.addEventListener 'DOMContentLoaded', _runScripts
else
  throw "window.addEventListener is not supported"
