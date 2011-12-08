###
###
class UMLClassDSL
    constructor: (@_diagram) ->

UMLClassDSL::def = (props) ->
    #if $.jumly.identify props
    #  UMLUsecaseDiagram supports normalizing. Have to port it.
    norm = $.jumly.normalize props
    @_diagram.appear norm

UMLClassDSL::class = UMLClassDSL::def

UMLClassDSL::start = (acts) ->  ## NOTE: Is there better name?
    acts.apply this, []

$.jumly.DSL.mixin UMLClassDSL

$.jumly.DSL type:".class-diagram", version:'0.0.1', compileScript: (script) ->
    diag = $.jumly ".class-diagram"
    ctxt = new UMLClassDSL(diag)
    ctxt.start ->
        eval CoffeeScript.compile script.html()
    diag

###
###
class UMLComponentDSL
    constructor: (@_diagram, @_component) ->

UMLComponentDSL::component = (name, acts) ->
    @_diagram.append compo = $.uml ".component", name
    ctxt = new UMLComponentDSL(@_diagram, compo)
    acts?.apply ctxt, []
    this

class UMLName
    constructor: (uname) ->
        if typeof uname is "string"
            @name = uname
        else
            for i of uname
                @name = i
                if typeof uname[i] is "object"
                    if $.isArray uname[i]
                        throw "#{i} MUST NOT be array"
                    else
                        $.extend this, uname[i]
    @_to = (uname) -> new UMLName uname

UMLComponentDSL::provide = (name) ->
    i = $.uml ".provided-interface", name
    @_component.append i
    this

UMLComponentDSL::require = (name) ->
    i = $.uml ".required-interface", name
    @_component.append i
    this

UMLComponentDSL::compose = (something) ->
    if typeof something is "function"
        something @_diagram
    else if typeof something is "object" and something.each
        something.append @_diagram
    else
        throw something + " MUST be a function or a jQuery object"
    @_diagram.compose()
    this

$.jumly.DSL.mixin UMLComponentDSL

mixin =
    component: (name, acts) ->
        diag = this
        ctxt = new UMLComponentDSL(diag)
        ctxt.component name, acts
        ctxt

## NOTE: This is WORKAROUND to append methods in other files.
a = $.uml ".component-diagram"
$.extend a.constructor.prototype, mixin


$.uml.diagram = (klass, name, others) ->
    acts = ([].slice.apply arguments).pop()
    unless $.isFunction acts
        throw "Last argument is expected a function"
    diag = $.uml "." + klass + "-diagram"
    ctxt = new UMLComponentDSL(diag)
    acts.apply ctxt, []
    ctxt
###
###
class DeploymentContext
    constructor: (@_diagram, @_deployment) ->

DeploymentContext::deployment = (name, acts) ->
    @_diagram.append compo = $.uml ".deployment", name
    ctxt = new DeploymentContext(@_diagram, compo)
    acts?.apply ctxt, []
    this

$.jumly.DSL.mixin DeploymentContext

mixin =
    deployment: (name, acts) ->
        diag = this
        ctxt = new DeploymentContext(diag)
        ctxt.deployment name, acts
        ctxt

## NOTE: This is WORKAROUND to append methods in other files.
a = $.uml ".deployment-diagram"
$.extend a.constructor.prototype, mixin
###
This class has information followings:
  - Current diagram instance
  - Current occurrence which is the last occurrence of actor.
###
class UMLSequenceDSL
    constructor: (props, @_diagram) ->
        $.extend this, props

UMLSequenceDSL::_find_or_create_ = (e) ->
    switch typeof e
        when "string"
            if @diagram[e]
                return @diagram[e]
            a = $.uml ".object", e
            a.attr id:e
            @diagram[e] = a
            @diagram.append a
            a
        when "object"
            e

UMLSequenceDSL::_actor = -> @_current_occurrence.gives ".object"

UMLSequenceDSL::message = (a, b, c) ->
    actname  = a
    if typeof b is "function" or b is undefined
        actee    = @_actor()
        callback = b
    else if typeof a is "string" and typeof b is "string"
        if typeof c is "function"
            actee    = @_find_or_create_ b
            callback = c
        else if c is undefined
            actee    = @_find_or_create_ b
            callback = null
    else if typeof a is "object" and typeof b is "string"
        actee    = @_find_or_create_ b
        callback = c
        for e of a
            switch e
                when "asynchronous"
                    actname = a[e]
                    stereotype = "asynchronous" 
    else
        msg = "invalid arguments"
        console.log "UMLSequenceDSL::message", msg, a, b, c
        throw msg
        
    iact = @_current_occurrence.interact actee
    iact.name(actname)
        .stereotype(stereotype)

    ## unless callback then return null  ##NOTE: In progress for this spec.
    
    occurr = iact.gives ".actee"
    ctxt = new UMLSequenceDSL(diagram:@diagram, _current_occurrence:occurr)
    callback?.apply ctxt, []
    ctxt

UMLSequenceDSL::create = (a, b, c) ->
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
        
    iact = @_current_occurrence.create id:actee, name:actee
    if name then iact.name name

    ## unless callback then return null  ##NOTE: In progress for this spec.
    
    occurr = iact.gives ".actee"
    ctxt = new UMLSequenceDSL(diagram:@diagram, _current_occurrence:occurr)
    callback?.apply ctxt, []
    ctxt

UMLSequenceDSL::destroy = (a) ->
    @_current_occurrence.destroy @_find_or_create_ a
    null

UMLSequenceDSL::reply = (a, b) ->
    @_current_occurrence
        .parents(".interaction:eq(0)").self()
        .reply name:a, ".actee":@_find_or_create_ b
    null

UMLSequenceDSL::ref = (a) ->
    ($.uml ".ref", a).insertAfter @_current_occurrence.parents(".interaction:eq(0)")
    null

UMLSequenceDSL::lost = (a) ->
    @_current_occurrence.lost()
    null

## A kind of fragment
UMLSequenceDSL::loop = (a, b, c) ->
    ## NOTE: Should this return null in case of no context
    if a.constructor is this.constructor  ## First one is DSL
        frag = a._current_occurrence
         .parents(".interaction:eq(0)").self()
         .fragment(name:"Loop")
         .addClass "loop"
    else
        last = [].slice.apply(arguments).pop()  ## Last one is Function
        if $.isFunction(last)
            kids = @_current_occurrence.find("> *")
            last.apply this, []
            newones = @_current_occurrence.find("> *").not(kids)
            if newones.length > 0
                frag = $.jumly(".fragment").addClass("loop").enclose newones
                frag.find(".name:first").html "Loop"
    this

## A kind of fragment
UMLSequenceDSL::alt = (ints, b, c) ->
    iacts = {}
    self = this
    for name of ints
        unless typeof ints[name] is "function"
            break
        act = ints[name]
        _new_act = (name, act) -> ->  ## Double '->' is in order to bind name & act in this loop.
            what = act.apply self
            unless what then return what
            what._current_occurrence
                .parent(".interaction:eq(0)")
        iacts[name] = _new_act(name, act)
    @_current_occurrence.interact stereotype:".alt", iacts
    this

###
Examples:
  - @reactivate "do something", "A"
  - @reactivate @message "call a taxi", "Taxi agent"
###
UMLSequenceDSL::reactivate = (a, b, c) ->
    if a.constructor is this.constructor
        e = a._current_occurrence.parents(".interaction:eq(0)")
        @_actor().activate().append e
        return a

    occurr = @_actor().activate()
    ctxt = new UMLSequenceDSL(diagram:@diagram, _current_occurrence:occurr)
    ctxt.message(a, b, c)
    ctxt

###
Note on a nearby interaction.
###
UMLSequenceDSL::note = (a, b, c) ->
    nodes = @_current_occurrence.find("> .interaction:eq(0)")
    if nodes.length is 0
        nodes = @_current_occurrence.parents ".interaction:eq(0):not(.activated)"

    ##TENTATIVE: because DSL notation is not decided.
    text = a
    opts = b
    note = $.uml ".note", text
    if opts
        note.attach nodes, opts
    else
        nodes.append note

###
opts is passed to .diagram#compose, as is.
###
UMLSequenceDSL::compose = (opts) ->
    if typeof opts is "function"
        opts @diagram
    else
        opts?.append @diagram
    @diagram.compose opts

$.jumly.DSL.mixin UMLSequenceDSL


mixin =
    found: (something, callback) ->
        diag = this
        ctxt = new UMLSequenceDSL diagram:diag, diag
        actor = ctxt._find_or_create_ something
        ctxt._current_occurrence = actor.activate()
        ctxt.last = callback?.apply(ctxt, [ctxt])
        ctxt

UMLSequenceDSL::preferences = ->
    @diagram.preferences.apply @diagram, arguments

## NOTE: This is WORKAROUND to append methods in other files.
a = $.uml ".sequence-diagram"
$.extend a.constructor.prototype, mixin

##
$.jumly.DSL type:'.sequence-diagram', version:'0.0.1', compileScript: (script) ->
    diag = $.jumly '.sequence-diagram'
    diag.found_ = -> eval CoffeeScript.compile script.html()
    diag.found_()
    diag

###
###
class UMLUsecaseDSL
    constructor: (@_diagram, @_boundary) ->

UMLUsecaseDSL::new_ = (type, uname) ->
    uname = $.jumly.normalize uname
    a = $.uml type, uname
    $.extend a.data("uml:property"), uname
    a

UMLUsecaseDSL::usecase = (uname) -> @create_ ".use-case", @_boundary, @usecase, uname
UMLUsecaseDSL::use_case = -> @usecase.apply this, arguments

UMLUsecaseDSL::actor = (uname) -> @create_ ".actor", @_diagram, @actor, uname

curry_ = (me, func, id) ->
    return (args) ->
        attrtext = $.jumly.normalize.apply null, arguments
        attrtext.id = id
        vals = [].slice.apply arguments
        vals[0] = attrtext
        func.apply me, vals

UMLUsecaseDSL::create_ = (type, target, func, uname) ->
    if id = $.jumly.identify uname
        return curry_ this, func, id
    a = @new_ type, uname
    target.append a

UMLUsecaseDSL::boundary = (name, acts) ->
    name ?= ""
    if id = $.jumly.identify name
        return curry_ this, @boundary, id
    boundary = @new_ ".system-boundary", name

    acts.apply ctxt = new UMLUsecaseDSL(@_diagram, boundary)
    if @_boundary
        @_boundary.append boundary
    else
        @_diagram.append boundary
    this

UMLUsecaseDSL::compose = (something) ->
    if typeof something is "function"
        something @_diagram
    else if typeof something is "object" and something.each
        something.append @_diagram
    else
        throw something + " MUST be a function or a jQuery object"
    @_diagram.compose()
    this

$.jumly.DSL.mixin UMLUsecaseDSL


mixin =
    boundary: (name, acts) ->
        ctxt = new UMLUsecaseDSL(this)
        ctxt.boundary name, acts
        ctxt

## NOTE: This is WORKAROUND to append methods in other files.
a = $.uml ".use-case-diagram"
$.extend a.constructor.prototype, mixin

$.jumly.DSL type:".use-case-diagram", version:'0.0.1', compileScript: (script) ->
    diag = $.jumly ".use-case-diagram"
    sbname = $(script).attr "system-boundary-name"
    diag.boundary sbname, ->
        unless sbname
            @_boundary.addClass("out-of-bounds").removeClass("system-boundary")
                      .find(".name").remove()
        eval CoffeeScript.compile script.html()
    diag

