###
# jumly for jQuery library to render UML diagram.
This is a top comment.
This line is 2nd line comment.
This is a 2nd paragraph.
###
###
# Top level function.
## 2nd level header.
###
uml = (_, opts) ->
    if (typeof _ is "object" && !_.type)
        return from_jQuery(_)
    
    _ = jQuery.extend({}, if typeof _ is "string" then {type:_} else _)
    meta = uml.factory[_.type]
    if (meta is undefined)
        throw "unknown type '" + _.type + "'"
    
    factory = meta.factory
    opts = $.extend {name:null}, if typeof opts is "object" then opts else {name:opts}
    a = factory(_, opts)  #/FIXME: depends on the class.
    a.attr("uml:type", _.type)
    a.find(".name:eq(0)").html(opts.name)
    a.name(opts.name) if opts.name
    a.attr id:opts.id if opts.id
    
    # Common methods
    a.gives = jQuery.uml.lang._gives(a, _)
    a.data("uml:this", a)
    a.data "uml:property", type:_.type, name: opts.name, stereotypes: -> []
    a

###
  + @param _ hash
###
from_jQuery = (_) ->
    if (typeof _ is "object" && !(typeof _.length is "number" && typeof _.data is "function"))
        _ = $(_)  # regard as a DOM node
    for i in [0.._.length-1]
        a = $(_[i]).data("uml:this")
        _[i] = if !a then null else a
    
    return _

###
  jumly parameter
###
uml.normalize = (a, b) ->
    return a if a is undefined or a is null
    switch typeof a
        when "string" then return $.extend name:a, b
        when "boolean", "number" then return null
    return null if $.isArray a
    return a if a.hasOwnProperty "id"
    r = {}
    for key, val of a
        if typeof key is "string" and key.match(/[0-9]+/) and typeof val is "string"
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


###
# Declaration for all attr keys of jQuery this library uses.
###
uml.factory = (name, fact) ->
    uml.factory[name] = {factory: fact}
name2type = {}
uml.def = (name, type) ->
    jQuery.uml.factory name, (_, opts) -> new type _, opts

## Packaging
pkgs = {}
uml.require = (pkgname, pkg) ->
    unless pkg
        return pkgs[pkgname] or (pkgs[pkgname] = {})
    pkgs[pkgname] = pkg

## Export uml module into jQuery.
jQuery.uml = jQuery.extend uml, jQuery.uml
jQuery.jumly = jQuery.uml


###
Comtenplating the location and the filename for utility methods.
###
uml.centeringToParent = (nodes) ->
    f = (i, e) ->
        e = $(e).css("position", "absolute")
        w = e.outerWidth()
        e.css("position", "relative")
         .width(w)
         .css "margin-left":"auto", "margin-right":"auto"
    nodes.each f

### Make alias ###
uml.alias = (str) ->
    a = str.split new RegExp("[ \-]+")
    (a.map (e) -> e[0]).join("").toLowerCase()


##
jQuery.uml.lang = {}
jQuery.uml.lang._gives = (a, dic) ->
	gives = (query) ->
        r = dic[query]
        if r then r else null
	if !a.gives
		return gives
	f = a.gives
	return (query) ->
        r = f(query)
        if r.length > 0 or r.of or r.as
            return r
        gives(query)

_as = (m) ->
	return {
		as:(e) -> m[e]
	}

jQuery.uml.lang._as = _as
jQuery.uml.lang._of = (nodes, query) ->
	return (unode) ->
		n = nodes.filter((i, e) ->
			e = jQuery.uml(e)[0]
			s = e.gives(unode.attr("uml:type"))
			if s is unode then e else null
		)
		if n.length > 0 then jQuery.uml(n)[0] else []

run_scripts_done = false
run_scripts = ->
    if run_scripts_done then return null
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


## Tooltip funciton
##
$_body = $("body")
_twipsy = (text, target = $_body) ->
    tip = $("<div>").addClass("twipsy")
              .append($("<div>").addClass("twipsy-arrow"))
              .append($("<div>").addClass("twipsy-inner").html(text))
    tip.appendTo target
    tip

$.jumly.vendor =
    bootstrap:
        twipsy: _twipsy

$.fn.twipsy = (text, pos) ->
    t = _twipsy text, @parent()
    t.alignAt this, pos

jQuery.fn.name = (n)->
  return @data("uml:property")?.name if arguments.length is 0 or n is undefined
  @find(".name:eq(0)").html n
  @data("uml:property")?.name = n
  this
jQuery.fn.stereotype = (n)->
  return @data("uml:property")?.stereotype if arguments.length is 0 or n is undefined
  @find(".stereotype:eq(0)").html n
  @data("uml:property")?.stereotype = n
  switch @attr("uml:type")
    when ".interaction" then @find(".message:eq(0)").data("uml:this").stereotype n
    when ".message" then @addClass n
  this
jQuery.fn.right = -> @offset().left + @width() - 1
jQuery.fn.outerBottom = -> @offset().top + @outerHeight() - 1

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
            (load_script "#{vendor_dir}/jquery-1.6.2.min.js").next(-> load_script "#{vendor_dir}/jquery.client.js"),
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