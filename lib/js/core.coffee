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
  self.require = JUMLY.require = require
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

_new_builder = (type)-> (script)-> (new (self.require type)).build script.html()
_new_layout  = (type)-> (diagram)-> (new (self.require type)).layout diagram

_compilers =
  '.sequence-diagram': _new_builder "SequenceDiagramBuilder"
  '.robustness-diagram': _new_builder "RobustnessDiagramBuilder"

_layouts =
  '.sequence-diagram': _new_layout "SequenceDiagramLayout"
  '.robustness-diagram': _new_layout "RobustnessDiagramLayout"

_runScripts = ->
  scripts = document.getElementsByTagName 'script'
  diagrams = (s for s in scripts when s.type.match /text\/jumly+(.*)/)
  for script in diagrams
    unless $(script).data 'jumly-evaluated'
      _evalHTMLScriptElement script
      $(script).data 'jumly-evaluated', true
  #$("body").trigger $.Event("ran.jumly")
  null

# Listen for window load, both in browsers and in IE.
unless core.env.is_node
  if typeof $ isnt 'undefined'
    $(window).on 'DOMContentLoaded', _runScripts
  else if window.addEventListener
    window.addEventListener 'DOMContentLoaded', _runScripts
  else
    throw "window.addEventListener is not supported"
