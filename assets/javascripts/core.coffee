uml = (arg, opts) ->
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
  meta = uml.factory[arg.type]
  if (meta is undefined)
    throw "unknown type '" + arg.type + "'"
  
  factory = meta.factory
  opts = $.extend {name:null}, if typeof opts is "object" then opts else {name:opts}
  a = factory(arg, opts)
  a.find(".name:eq(0)").html(opts.name)
  a.name(opts.name) if opts.name
  a.attr id:opts.id if opts.id
  
  # Common methods
  a.gives = $.uml.lang._gives(a, arg)
  a.data "uml:property", _self:a, type:arg.type, name: opts.name, stereotypes: -> []
  a

$.fn.self = -> @data("uml:property")?._self

## Normalize as JUMLY Parameter
##
uml.normalize = (a, b) ->
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

## Declaration for all attr keys of jQuery this library uses.
uml.factory = (name, fact)-> uml.factory[name] = factory:fact

uml.def = (name, type)-> uml.factory name, (_, opts)-> new type _, opts

## Export uml module into $.
$.uml = $.extend uml, $.uml
$.jumly = $.uml

##
$.jumly.lang =
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
  			e = $.uml(e)[0]
  			s = e.gives(unode.data("uml:property").type)
  			if s is unode then e else null
  		if n.length > 0 then $.uml(n)[0] else []

run_scripts_done = false
run_scripts = ->
  return null if run_scripts_done 
  scripts = document.getElementsByTagName 'script'
  diagrams = (s for s in scripts when s.type.match /text\/jumly+(.*)/)
  for script in diagrams
    uml.run_script_ script
  run_scripts_done = true
  null

uml.runScripts_ = run_scripts

uml[':preferences'] =
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

uml.run_script_ = (script) ->
  script = $ script
  type = script.attr("type")
  unless type then throw "Not found: type attribute in script"
  unless type.match /text\/jumly-(.*)-diagram|text\/jumly\+(.*)/ then throw "Illegal type: #{type}"
  kind = RegExp.$1 + RegExp.$2
  compiler = $.jumly.DSL ".#{kind}-diagram"
  unless compiler then throw "Not found: compiler for '.#{kind}'"
  unless compiler.compileScript then throw "Not found: compileScript"
  diag = compiler.compileScript script

  prefs = $.jumly[':preferences'].run_script
  target = prefs.determine_target script
  prefs.before_compose diag, target, script
  diag.compose()

# Listen for window load, both in browsers and in IE.
if window.addEventListener
    addEventListener 'DOMContentLoaded', run_scripts, no
else
    throw "window.addEventListener is not supported"

$.jumly.identify = (e) ->
    unless e
        return null
    if (p for p of e).length is 1 and p is "id"
        switch typeof e.id
            when "number", "string" then e.id
            when "function" then e.id()
            else return null


##
prefs_ = {}
preferences_ = (a, b) ->
    if !b and typeof a is "string"
        return prefs_[a]
    prefs_[a] = $.extend prefs_[a], b

$.jumly.preferences = preferences_

$.fn.name = (n)->
  return @data("uml:property")?.name if arguments.length is 0 or n is undefined
  @find(".name:eq(0)").html n
  @data("uml:property")?.name = n
  this
$.fn.stereotype = (n)->
  return @data("uml:property")?.stereotype if arguments.length is 0 or n is undefined
  @find(".stereotype:eq(0)").html n
  @data("uml:property")?.stereotype = n
  switch @data("uml:property").type
    when ".interaction" then @find(".message:eq(0)").self().stereotype n
    when ".message" then @addClass n
  this
$.fn.right = -> @offset().left + @width() - 1
$.fn.outerBottom = -> @offset().top + @outerHeight() - 1

###
(->
    head = document.getElementsByTagName("head")[0]
    load_css_ = (href, callback) ->
        node = document.createElement 'link'
        node.type   = 'text/css'
        node.rel    = 'stylesheet'
        node.href   = href
        node.media  = 'screen'
        node.onload = callback
        head.appendChild(node)
    
    load_script_ = (src, callback) ->
        node = document.createElement 'script'
        node.type   = 'text/javascript'
        node.src    = src
        node.onload = callback
        head.appendChild(node)
    
    load_script = (src) ->
        deferred = new Deferred()
        load_script_ src, -> deferred.call.apply deferred, arguments
        deferred

    take = (resource, scriptNode) ->
        $.get resource, (res) ->
            e = $("<script>").attr(type:"text/jumly+sequence").html(res)
            e.insertAfter scriptNode
            $.jumly.run_script_ e

    queue = []
    window.JUMLY =
        load: (resource) ->
            scripts = document.getElementsByTagName("script")
            me = scripts[scripts.length - 1]
            if window.jQuery?.jumly
                take resource, me
            else
                queue.push script:me, resource:resource
    
    css_dir    = "/stylesheets"
    vendor_dir = "/vendor"
    js_dir     = '/javascripts'

    load_css_ "#{css_dir}/jumly-min.css"
 
    load_script_ "#{vendor_dir}/jsdeferred.js", ->
        Deferred.parallel([
            (load_script "#{vendor_dir}/jquery-1.6.2.min.js").next(-> load_script "#{vendor_dir}/$.client.js"),
            load_script "#{vendor_dir}/coffee-script.min-1.1.1.js",
            load_script "#{vendor_dir}/cssua.min.js",
        ]).next(->
            $("html").addClass $.client.os
            load_script "#{js_dir}/jumly-min.js"
        ).next(->
            $(queue).each (i, e) -> take e.resource, e.script
            $.jumly.runScripts_()
        )
) this
###
