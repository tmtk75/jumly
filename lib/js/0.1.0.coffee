jumly = $.jumly

SCRIPT_TYPE_PATTERN = /text\/jumly-(.*)-diagram|text\/jumly\+(.*)|application\/jumly\+(.*)/
_to_type_string = (type)->
  unless type.match SCRIPT_TYPE_PATTERN then throw "Illegal type: #{type}"
  kind = RegExp.$1 + RegExp.$2 + RegExp.$3

evalHTMLScriptElement = (script) ->
  script = $ script
  type = script.attr("type")
  throw "Not found: type attribute in script" unless type 
  kind = _to_type_string type
  compiler = _dsl ".#{kind}-diagram"
  throw "Not found: compiler for '.#{kind}'" unless compiler
  throw "Not found: compileScript" unless compiler.compileScript 
  diag = compiler.compileScript script

  _before = (diag, target, script)->
    if target[0]?.localName is "head" then diag.appendTo $ "body"
    else if script.attr("target-id") then target.html diag
    else diag.insertAfter script
  
  _determine = (script)->
    targetid = script.attr "target-id"
    if targetid then $ "##{targetid}"
    else script.parent()

  target = _determine script
  _before diag, target, script
  diag.compose()

dsl_ = {}
_dsl = (args) ->
  throw "It MUST NOT be null." if args is null
  return dsl_[args] if typeof args is "string"
  throw "DSL can only accept an object." unless typeof args is "object" and not $.isArray args
  throw "type property is required." unless args.type
  throw "compileScript property is required." unless args.compileScript
  dsl_[args.type] = {compileScript:args.compileScript, version:args.version}

DSL = _dsl

_runScripts = ->
  return null if _runScripts.done 
  scripts = document.getElementsByTagName 'script'
  diagrams = (s for s in scripts when s.type.match /text\/jumly+(.*)/)
  for script in diagrams
    JUMLY.evalHTMLScriptElement script
  _runScripts.done = true
  null

# Listen for window load, both in browsers and in IE.
if window.addEventListener
  window.addEventListener 'DOMContentLoaded', _runScripts
else
  throw "window.addEventListener is not supported"
