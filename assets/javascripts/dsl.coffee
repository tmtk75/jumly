###
###
class DeploymentContext extends JUMLY.DSLEvents_
    constructor: (@_diagram, @_deployment) ->

DeploymentContext::deployment = (name, acts) ->
    @_diagram.append compo = $.uml ".deployment", name
    ctxt = new DeploymentContext(@_diagram, compo)
    acts?.apply ctxt, []
    this

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
class UMLSequenceDSL extends JUMLY.DSLEvents_
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
