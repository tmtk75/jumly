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

run_scripts_done = false
run_scripts = ->
  return null if run_scripts_done 
  scripts = document.getElementsByTagName 'script'
  diagrams = (s for s in scripts when s.type.match /text\/jumly+(.*)/)
  for script in diagrams
    jumly.run_script_ script
  run_scripts_done = true
  null

jumly_preferences_ =
  run_script:
    before_compose: (diag, target, script) ->
      if target[0]?.localName is "head"
        diag.appendTo $ "body"
      else if script.attr("target-id")
        target.html diag
      else
        diag.insertAfter script
    determine_target: (script) ->
      targetid = script.attr "target-id"
      if targetid
        $ "##{targetid}"
      else
        script.parent()

SCRIPT_TYPE_PATTERN = /text\/jumly-(.*)-diagram|text\/jumly\+(.*)|application\/jumly\+(.*)/
toTypeString = (type)->
  unless type.match SCRIPT_TYPE_PATTERN then throw "Illegal type: #{type}"
  kind = RegExp.$1 + RegExp.$2 + RegExp.$3

jumly.run_script_ = (script) ->
  script = $ script
  type = script.attr("type")
  unless type then throw "Not found: type attribute in script"
  kind = toTypeString type
  compiler = jumly.DSL ".#{kind}-diagram"
  unless compiler then throw "Not found: compiler for '.#{kind}'"
  unless compiler.compileScript then throw "Not found: compileScript"
  diag = compiler.compileScript script

  prefs = jumly_preferences_.run_script
  target = prefs.determine_target script
  prefs.before_compose diag, target, script
  diag.compose()

# Listen for window load, both in browsers and in IE.
if window.addEventListener
  addEventListener 'DOMContentLoaded', run_scripts
else
  throw "window.addEventListener is not supported"

jumly.build = (script)->
  type = toTypeString script.attr "type"
  builderType = (
    switch type
      when "class"    then JUMLY.ClassDiagramBuilder
      when "usecase"  then JUMLY.UsecaseDiagramBuilder
      when "sequence" then JUMLY.SequenceDiagramBuilder
  )
  (new builderType).build script.text()
