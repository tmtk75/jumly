jumly = $.jumly

jumly.identify = (e)->
  unless e then return null
  if (p for p of e).length is 1 and p is "id"
    switch typeof e.id
      when "number", "string" then e.id
      when "function" then e.id()
      else return null

jumly.normalize = (a, b) ->
  return a if a is undefined or a is null
  switch typeof a
    when "string" then return $.extend name:a, b
    when "boolean", "number" then return null
  return null if $.isArray a
  return a if a.hasOwnProperty "id"
  r = {}
  for key, val of a
    if typeof key is "string" and key.match(/[1-9][0-9]*/) and typeof val is "string"
      r.id = parseInt key
      r.name = val
    else
      r[key] = val
  if r.hasOwnProperty "name"
    r
  else
    r.name = key
    attrs = r[key]
    delete r[key]
    $.extend r, attrs

jumly.lang =
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
