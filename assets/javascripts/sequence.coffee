class UMLMessage
    constructor: (props, opts) ->
        jQuery.extend this, UMLMessage.newNode()
    @newNode = ->
        $("<div>").addClass("message")
                  .append($("<canvas>").addClass "arrow")
                  .append($("<div>").addClass "name")

UMLMessage::to_line = (canvas) ->  # For backward compatibility.
    @_line_to_next_occurrence canvas

UMLMessage::_line_to_next_occurrence = (canvas) ->
    if false #@hasClass("destroy")) {
        ##FIXME: Destroy message
        console.log "FIXME: to avoid runtime error."
        {src:{x:0, y:0}, dst:{x:400, y:0}}
    srcll = @_src_occurr this
    dstll = @_dst_occurr this
    @_to_line srcll, dstll, canvas

UMLMessage::_to_line = (srcll, dstll, canvas) ->
    # Lost message is always toward right.
    if !@parent().hasClass("lost") and @isTowardLeft()
        {
            src:
                x: srcll.offset().left - @offset().left
                y: canvas.outerHeight()/2
            dst:
                x: dstll.outerWidth()
                y: canvas.outerHeight()/2
        }
    else
        {
            src:
                x: srcll.outerWidth()
                y: canvas.outerHeight()/2
            dst:
                x: dstll.offset().left - srcll.offset().left
                y: canvas.outerHeight()/2
        }

UMLMessage::_src_occurr = (msg) ->
    jQuery.uml(msg.parents(".occurrence")[0])[0]

UMLMessage::_dst_occurr = (msg) ->
    jQuery.uml(if msg.hasClass "return" then msg.prev ".occurrence" else $ "~ .occurrence", msg)[0]

UMLMessage::_canvas = ->
    @find("canvas:eq(0)")
        .attr(width:@width(), height:@height())
        .css (width:@width(), height:@height())

UMLMessage::_to_create_line = (canvas) ->
    e = @_to_line @_src_occurr(this), @_dst_occurr(this).gives(".object"), canvas
    if @isTowardLeft()
        src = @_src_occurr(this)
        e.dst.x = src.gives(".object").outerRight() - src.offset().left
    e

UMLMessage::_find_occurrence = (actee) ->
    occurr = null
    @parents(".occurrence").each (i, e) =>
        e = $(e).self()
        if e.gives(".object") is actee
            occurr = e
    occurr

MESSAGE_STYLE =
    width      : 1
    base       : 6
    height     : 10
    lineWidth  : 1.5
    shape      : "line2"
    pattern    : [8, 8]
    strokeStyle: 'gray'
    fillStyle  : 'gray'

STEREOTYPE_STYLES =  # From streotype to style object 
    create      : {shape: "dashed"}
    asynchronous: {shape: "line"}
    synchronous : {shape: "line2", fillStyle: 'gray'}
    destroy     : {shape: "line2", fillStyle: 'gray'}

_determine_primary_stereotype = (jqnode) ->
    for e in ["create", "asynchronous", "synchronous", "destroy"]
        if jqnode.hasClass e
            return e

UMLMessage::repaint = (style) ->
    arrow = jQuery.extend {}, MESSAGE_STYLE, style, STEREOTYPE_STYLES[_determine_primary_stereotype this]
    # Canvas element has width x height property of CSS and posseses width x height attribute as DOM element.
    # So if you don't set same value to both, the rendered result may be inconsistent.
    canvas = @_current_canvas = @_canvas()

    if style?.inherit
        p = @parents(".occurrence:eq(0)")
        arrow.fillStyle   = p.css "background-color"
        arrow.strokeStyle = p.css "border-top-color"
        (p.css "box-shadow").match /(rgba\(.*\)) ([0-9]+)px ([0-9]+)px ([0-9]+)px ([0-9]+)px/
        arrow.shadowColor   = RegExp.$1
        arrow.shadowOffsetX = RegExp.$2
        arrow.shadowOffsetY = RegExp.$3
        arrow.shadowBlur    = RegExp.$4

    if arrow.self
        ctxt = canvas[0].getContext '2d'
        gap = 2
        rcx = @width() - (gap + 4)
        rey = @height() - (arrow.height/2 + 4)
        llw = @_dst_occurr(this).outerWidth()
        $.g2d.arrow ctxt, {x:rcx, y:rey}, {x:llw + gap,  y:rey}, arrow
        arrow.base = 0
        $.g2d.arrow ctxt, {x:llw/2 + gap, y:gap}, {x:rcx, y:gap}, arrow
        $.g2d.arrow ctxt, {x:rcx,         y:gap}, {x:rcx, y:rey}, arrow
        return this

    if @hasClass "create"
        line = @_to_create_line canvas
    else if @gives ".actee"
        newsrc = @_find_occurrence @gives ".actee"
        newdst = @_dst_occurr(this)
        line = @_to_line newsrc, newdst, canvas
    else
        line = @_line_to_next_occurrence canvas
        
    if arrow.reverse
        a           = line.src
        line.src    = line.dst
        line.dst    = a
        arrow.shape = 'dashed'
        
    jQuery.g2d.arrow canvas[0].getContext('2d'), line.src, line.dst, arrow
    this

UMLMessage::isToward = (dir) ->
    iact = @gives(".interaction")
    if "right" is dir
        iact.gives(".occurrence").as(".actor")
            .gives(".object").isLeftAt(iact.gives(".occurrence").as(".actee")
                                             .gives(".object"))
    else if "left" is dir
        iact.gives(".occurrence").as(".actor")
            .gives(".object").isRightAt(iact.gives(".occurrence").as(".actee")
                                              .gives(".object"))

UMLMessage::isTowardRight = ->
    @isToward "right"

UMLMessage::isTowardLeft = ->
    @isToward "left"

UMLMessage::_compose_looks_of_creation = ->
    srcoccur = @_src_occurr(this)
    dstoccur = @_dst_occurr(this)
    render = (msg) ->
        msg.repaint()
           .gives(".interaction").gives(".occurrence").as(".actee")
           #.css(border:"none", "background-color":"transparent")
        
    preffered_width = (msg) ->
        l = msg._to_line srcoccur, dstoccur.gives(".object"), msg
        Math.abs l.src.x - l.dst.x
        
    centering_name = (msg, newwidth) ->
        if msg.isTowardLeft()
            return
        newleft = srcoccur.outerWidth() + msg.offset().left + (newwidth - msg.find(".name").outerWidth())/2
        msg.find(".name").offset(left:newleft)
        
    shift_down_lifeline = (obj) ->
        diag = obj.parents ".sequence-diagram"
        ll = $ ".lifeline .line:eq(1)", diag  # Should be derrived from obj. 
        prevtop = ll.offset().top
        ll.offset(top:obj.offset().top + obj.outerHeight())
        ll.height ll.height() - (ll.offset().top - prevtop)
    
    shift_downward = (msg) ->
        created.offset top:msg.offset().top - created.height()/3
        y = created.outerBottom() + parseInt dstoccur.css "margin-top"
        dstoccur.offset(top:y)
       #         .addClass ""
        iact = msg.parents(".interaction:eq(0)")
        dy = iact.outerBottom() - dstoccur.outerBottom() - parseInt dstoccur.css "margin-top"
        iact.css "margin-bottom", (Math.abs dy) 

    
    created = dstoccur.gives ".object"
    w = preffered_width this
    shift_downward this
    render this
    centering_name this, w
    shift_down_lifeline created

jQuery.uml.def ".message", UMLMessage
class UMLInteraction
    constructor: (props, opts) ->
        jQuery.extend this, UMLInteraction.newNode()
        msg = jQuery.uml type:".message", ".interaction":this
        props[".message"] = msg  ## FIXME: Can I remove this?
        @append(msg)
    @newNode = ->
        $("<div>").addClass "interaction"

UMLInteraction::interact = (obj) ->
    @awayfrom().interact obj
UMLInteraction::forward = (obj) ->
    @toward()
UMLInteraction::taking= (f) ->
    f(this)
    this

UMLInteraction::to = (func) ->
    occurrs = @gives(".occurrence")
    tee = occurrs.as(".actee")
    tor = occurrs.as(".actor")
    func(tee, tor)

UMLInteraction::forwardTo = -> @gives(".occurrence").as ".actee"
UMLInteraction::backwardTo = -> @gives(".occurrence").as ".actor"
UMLInteraction::toward = -> @forwardTo()
UMLInteraction::awayfrom = (obj) ->
    return @backwardTo() unless obj
    
    for e in @parents(".occurrence").not(".activated")
        e = $(e).self()
        return e if e?.gives(".object") is obj

    obj.activate()

UMLInteraction::_build = ->
    that = this
    a   = dstoccurr = that.gives(".occurrence").as ".actor"
    b   = srcoccurr = that.gives(".occurrence").as ".actee"
    msg = jQuery.uml($ "> .message", that)[0]
    # Self-invokation case
    if @isToSelf()
        @_build_self_invocation a, b, msg
        return
		
    # Normal message
    w = a.offset().left - (b.offset().left + $(".occurrence:eq(0)", that).width())
    if @hasClass("lost")
        msg.height b.outerHeight()
    else if msg.isTowardLeft()
        w = b.offset().left - (a.offset().left + $(".occurrence:eq(0)", that).width())

    msg.width(Math.abs(w))
       .offset(left:Math.min(a.offset().left, b.offset().left))
       .repaint()

    # Locate the name of message
    # Normal message
    #TODO: Move this centering logic for name to .message class. 

    # Return message
    rmsg = $("> .message.return:last", that).self()
    if rmsg
        x = msg.offset().left
        if rmsg.gives ".actee"
            newdst = rmsg._find_occurrence(rmsg.gives ".actee")
            w = srcoccurr.offset().left - newdst.offset().left
            x = Math.min srcoccurr.offset().left, newdst.offset().left
        rmsg.width(Math.abs w)
            .offset(left:x)
            .repaint(reverse:true)

UMLInteraction::_build_self_invocation = (a, b, msg) ->
    w = @find(".occurrence:eq(0)").outerWidth()  ## It's based on the width of occurrence.
    dx = w*2
    dy = w*1
    b.css top:0 + dy          # Shift the actee occurrence to y-positive
    @css "padding-bottom":dy  # To expand the height of occurrence of actor

    msg.css(top:0)
       .width(b.width() + dx)
       .height(b.offset().top - msg.offset().top + dy + w/8)
       .offset left:b.offset().left
    
    msg.repaint self:true

    arrow = msg.find ".arrow"
    msg.find(".name").offset
        left: arrow.offset().left + arrow.outerWidth()
        top : arrow.offset().top

UMLInteraction::reply = (p) ->
    @addClass "reply"
    a = $.uml(type:".message", ".interaction":this, ".actee":p?[".actee"]).addClass("return")
        .insertAfter @children ".occurrence:eq(0)"
    if p?.name
        a.name p.name
    this

UMLInteraction::fragment = (attrs, opts) ->
    frag = $.uml(type:".fragment")
    frag.enclose(this)
   
UMLInteraction::isToSelf = ->
    a = @gives(".occurrence").as ".actor"
    b = @gives(".occurrence").as ".actee"
    unless a && b
        return false
    a.gives(".object") is b.gives(".object")

jQuery.uml.def ".interaction", UMLInteraction

###
###
UMLInteraction::is_to_itself = -> @isToSelf()


class UMLLifeline
    constructor: (props, opts) ->
        jQuery.extend this, UMLLifeline.newNode props
    @newNode = (props) ->
	    $("<div>").addClass("lifeline")
	              .append($("<div>").addClass("line").height(128))
			      .width(props[".object"].width())
			      .height(128)

jQuery.uml.def ".lifeline", UMLLifeline
_as = jQuery.uml.lang._as
class UMLOccurrence
    constructor: (props, opts) ->
        jQuery.extend this, UMLOccurrence.newNode()
    @newNode = ->
        $("<div>").addClass("occurrence")

###
NOTE: It's inconsistent.
  To make combined fragment,
    
      frag.interact(stereotype:.alt, {"[cond-1]":act-1, "[cond-2]":act-2})
    
    act-1, act-2 are function receiving an argument which is an occurrence.
    They are able to be defined as follow,

      act1 = (occurr) -> occurr.interact object_1

    This makes an interaction to object_1 from current occurrence.
###
UMLOccurrence::interact = (_, opts) ->
    if opts?.stereotype is ".lost"
        occurr = jQuery.uml(type:".occurrence").addClass "icon"
        iact   = jQuery.uml type:".interaction", ".occurrence":_as(".actor":this, ".actee":occurr), ".actor":this, ".actee":occurr
        iact.addClass "lost"
    else if opts?.stereotype is ".destroy"
        #NOTE: Destroy message building
    else if _?.stereotype is ".alt"
        alt = $.uml ".fragment", name:"alt"
        alt.alter this, opts
        return this
    else
        occurr = jQuery.uml type:".occurrence", ".object":_
        iact   = jQuery.uml
                    "type"       : ".interaction"
                    ".occurrence": _as(".actor":this, ".actee":occurr)
                    ".object"    : _as(".actor":@gives(".object"), ".actee":_)
                    ".actor"     : this
                    ".actee"     : occurr
    iact.append(occurr).appendTo this
    iact

UMLOccurrence::create = (objsrc) ->
    obj = jQuery.uml ".object", objsrc.name
    obj.attr "id", objsrc.id
    @parents(".sequence-diagram").self()[objsrc.id] = obj
    @gives(".object").parent().append obj
    iact = (@interact obj).stereotype "create"
    iact

UMLOccurrence::move = ->
    if @parent().hasClass "lost"
        @offset left:@parents(".diagram").find(".object").mostLeftRight().right
        return this 
    if not @isOnOccurrence()
        left = @gives(".object").offset().left + (@gives(".object").width() - @width())/2
    else
        left = @parentOccurrence().offset().left
    left += @width()*@shiftToParent()/2
    @offset left:left #- $("body").css("margin-left").toInt()

UMLOccurrence::isOnOccurrence = ->
    not (@parentOccurrence() is null)

UMLOccurrence::parentOccurrence = ->
    lls = jQuery.uml(@parents(".occurrence"))
    return null if lls.length is 0

    for i in [0..lls.length - 1]
        if @gives(".object") is lls[i].gives(".object")
            return lls[i]
    null

UMLOccurrence::shiftToParent = ->
    return 0 if not @isOnOccurrence()
    # find a message contained in the same interaction together.
    a = jQuery.uml(@parent().find ".message:eq(0)")[0]
    return 0  if a is undefined
    return -1 if a.isTowardRight()
    return 1  if a.isTowardLeft()
    # in case of self-invokation below
    return 1

UMLOccurrence::preceding = (obj) ->
    f = (ll) ->
        a = jQuery.uml(ll.parents ".occurrence:eq(0)")[0]
        return null if !a
        return a    if a.gives(".object") is obj
        return f a
    f this

UMLOccurrence::destroy = (actee) ->
    #NOTE: expecting interface
    #return @interact(actee, {stereotype:"destroy"})
    #Tentative deprecated implementation.
    occur = @interact(actee)
                .stereotype("destroy")
                .gives(".occurrence").as(".actee")
    if occur.isOnOccurrence()
        occur = occur.parentOccurrence()
		
    $("<div>").addClass("stop")
              .append($("<div>").addClass("icon")
                                .addClass("square")
                                .addClass("cross"))
              .insertAfter(occur)
    occur

jQuery.uml.def ".occurrence", UMLOccurrence
class UMLFragment
    constructor: (props, opts) ->
        jQuery.extend this, UMLFragment.newNode()
    @newNode = ->
        $("<div>").addClass("fragment")
                  .append($("<div>").addClass("header")
                                    .append($("<div>").addClass("name"))
                                    .append($("<div>").addClass("condition")))

UMLFragment::enclose = (_) ->
    if not _? or _.length is 0
        throw "UMLFragment::enclose arguments are empty."
    if _.length > 1  # pre-condition: all nodes have same parent.
        a = $(_[0]).parent()[0]
        for i in [1 .. _.length - 1]
            b = $(_[i]).parent()[0]
            unless a is b
                throw {message:"different parent", nodes:[a, b]}
    if _.parent is undefined
        return this
    this.swallow(_)
    this

UMLFragment::extendWidth = (opts) ->
    frag = this
    dlw = opts?.left
    drw = opts?.right
    dlw ?= 0
    drw ?= 0
    frag.css("position", "relative")
        .css("left", -dlw)
        .width(frag.width() + dlw/2)
        .find("> .interaction")
           .css("margin-left", dlw)
    frag.width(frag.outerWidth() + drw)

###
  opts: expected {"[condiaion-1]": <action>, "[condition-1]": <action}
###
UMLFragment::alter = (occurr, opts) ->
    alt = this
    alt.addClass("alt")
       .find(".condition").remove()  # because each interaction has each condition
    occurr.append alt
    for name of opts
        act = opts[name]
        unless typeof act is "function"
            throw "#{name} is not function"
        iact = act occurr  ## expect iact type is ".interaction"
        if iact is null or iact is undefined then break
        unless iact
            throw "#{iact} of #{name}'s action returned is not appendable into .alt.fragment"
        alt.append($("<div>").addClass("condition").html name)
           .append(iact)
           .append $("<div>").addClass("divider")
    alt.find(".divider:last").remove()
    alt

jQuery.uml.def ".fragment", UMLFragment
###
# UMLRef
###
class UMLRef
    constructor: (props, opts) ->
	    jQuery.extend this, UMLRef.newNode()
    @newNode = ->
        $("<div>").addClass("ref")
	              .append($("<div>").addClass("header")
                                    .append($("<div>").addClass("tag")
                                                      .html "ref"))
                  .append $("<div>").addClass "name"

# preferredWidth
UMLRef::preferredWidth = ->
    diag = @parents(".sequence-diagram:eq(0)")
    iact = @prevAll(".interaction:eq(0)")

    if iact.length is 0
        lines = $(".lifeline .line", diag)
        most = lines.mostLeftRight()
        most.width = most.width()
        return most
   
    dh = diag.self()
            .find(".occurrence:eq(0)").width()
    occurs = iact.find(".occurrence")
    most = occurs.mostLeftRight()
    most.left -= dh
    most.width = most.width()
    most
    
    ### 
    diag = @parents ".diagram"
    most = $(".line", diag).mostLeftRight()
    most.left  -= dh + diag.offset().left
    most.right -=      diag.offset().left
    most.width = most.width() - (@outerWidth() - @width()) + dh
    most
    ### 

jQuery.uml.def ".ref", UMLRef
uml = jumly = jQuery.uml
class UMLSequenceDiagram
    constructor: (props, opts) ->
        jQuery.extend this, UMLSequenceDiagram.newNode()
        @gives = (query) =>
            e = @find(query)
            f = jQuery.uml.lang._of e, query
            {of: f}
        this
    @newNode = ->
        $("<div>").addClass("diagram")
                  .addClass("sequence-diagram")

UMLSequenceDiagram::debugshow = ->
    @prependTo $("body")
    @compose()

prefs_ =
    compose_most_left: 0
    compose_span     : 150 - (88 + 4)
    WIDTH : null
    HEIGHT: 50
jumly.preferences(".sequence-diagram", prefs_)
jumly.preferences(".sequence-diagram:system-default", prefs_)

UMLSequenceDiagram::$ = (sel) -> uml($(sel, this))
UMLSequenceDiagram::$0 = (typesel) -> @$(typesel)[0]
UMLSequenceDiagram::preferences = (a, b) ->
    prefs = @data("uml:property").preferences
    if !prefs then @data("uml:property").preferences = prefs = {}
    width = ->
        objs  = $(".object", this)
        left  = objs.min((e) -> $(e).position().left) - @position().left
        right = objs.max((e) -> $(e).position().left + $(e).outerWidth()) - @position().left
        left + (right - left) + left
    ## Return preferences
    if (!b and typeof a is "string") or (!a and !b)
        r = $.extend {}, $.jumly.preferences(".sequence-diagram"), prefs
        r.WIDTH = width.apply this
        return r
    ## Overrite instance preferences
    #console.log "setter", prefs
    $.extend prefs, a

rebuild_asynchronous_self_calling = (diag) ->
    diag.find(".message.asynchronous").parents(".interaction:eq(0)").each (i, e) ->
        e = $(e).self()
        if not e.isToSelf()
            return
        iact = e.addClass("activated")
                   .addClass("asynchronous")
        prev = iact.parents(".interaction:eq(0)")
        iact.insertAfter prev
        
        occurr = iact.css("padding-bottom", 0)
                     .find("> .occurrence").self()
                     .move()
                     .css("top", 0)

        msg = iact.find(".message").self()
        msg.css("z-index", -1)
           .offset
               left: occurr.offset().left
               top : prev.find(".occurrence").outerBottom() - msg.height()/3

UMLSequenceDiagram::compose = (props) ->
    try
        @trigger "beforeCompose", [this]
        @_compose props
        @trigger "afterCompose", [this]
        this
    catch ex
        console.log ex, {arguments:ex.arguments, stack:ex.stack, type:ex.type, message:ex.message, name:ex.name}
        throw ex

UMLSequenceDiagram::_compose = (props) ->
    prefs = @preferences()
    objects = @find(".object")
    align_objects_horizontally objects, prefs
    align_occurrences_horizontally uml $(".occurrence", this)
    build_interactions uml($ ".occurrence .interaction", this)
    generate_lifelines_and_align_horizontally this
    pack_object_lane_vertically this
    pack_refs_horizontally this
    pack_fragments_horizontally this
    align_creation_message_horizontally @find(".message.create")
    align_lifelines_vertically this
    align_lifelines_stop_horizontally @find(".stop")
    rebuild_asynchronous_self_calling this
    render_icons objects
    @width @preferredWidth()

    @trigger "composed", {diagram:this}  ## DEPRECATED: compose.after is better.
    this

render_icons = (objects) ->
    objects.each (i, e) ->
        $(e).self().renderIcon?()

align_objects_horizontally = (objs, alinfo) ->
    f0 = (a) ->
        if a.css("left") is "auto"
            a.css left:alinfo.compose_most_left
    f1 = (a, b) ->
        if b.css("left") is "auto"
            l = a.position().left + a.outerWidth() + alinfo.compose_span
            b.css left:l
    objs.pickup2 f0, f1

align_occurrences_horizontally = (occurrs) ->
    occurrs.each (i, occurr) -> occurr.move()

build_interactions = (iacts) ->
    iacts.each (i, iact) -> iact._build()

generate_lifelines_and_align_horizontally = (diag) ->
    $(".lifeline", diag).remove()
    $(".object", diag).each((i, e) ->
        obj = uml(e)[0]
        a = uml type:".lifeline", ".object":obj
        a.offset left:obj.offset().left, top:obj.outerBottom()  + 1
        a.insertAfter obj
    )

align_lifelines_vertically = (diag) ->
    #mostbottom = jQuery.max (diag.find "> *"), (e) -> $(e).offset().top + $(e).height()
    mostbottom = diag.find(".occurrence")
                     .not(".interaction.lost .occurrence")
                     #.css("border", "2px solid red")
                     #.outerBottom()
                     .max (e) -> $(e).outerBottom()
    $(".lifeline", diag).each (i, e) ->
        a = $(e).self()
        obj = a.gives(".object")
        y = obj.outerBottom() + 1
        a.offset left:obj.offset().left, top:y
        h = mostbottom - y + 16
        #$(e).css("border": "2px blue solid").append(h).append(",").append($(e).offset().top)
        $(e).height h
        $(e).find(".line").css(top:0).height h

pack_object_lane_vertically = (diag) ->
    return if $(".object-lane", diag).length > 0
    objs = $ ".object", diag
    mostheight = jQuery.max objs, (e) -> $(e).outerHeight()
    mostheight ?= 0
    $("<div>").addClass("object-lane")
              .height(mostheight)
              .swallow(objs)

pack_refs_horizontally  = (diag) ->
    refs = uml($ ".ref", diag)
    return if refs.length is 0
    $(refs).each (i, ref) ->
        pw = ref.preferredWidth()
        ref.offset(left:pw.left)
           .width(pw.width)

pack_fragments_horizontally = (diag) ->
    # fragments just under this diagram.
    fragments = $ "> .fragment", diag
    if fragments.length > 0
        # To controll the width, you can write selector below.
        # ".object:eq(0), > .interaction > .occurrence .interaction"
        most = $(".object", diag).mostLeftRight()
        left = fragments.offset().left
        fragments.width (most.right - left) + (most.left - left)
    
    # fragments inside diagram
    fixwidth = (i, fragment) ->
        most = $(".occurrence, .message, .fragment", fragment).not(".return, .lost").mostLeftRight()
        fragment = $(fragment)
        fragment.width(most.width() - (fragment.outerWidth() - fragment.width()))
        ## WORKAROUND: it's tentative for both of next condition and the body
        msg = uml(fragment.find("> .interaction > .message"))[0]
        if (msg?.isTowardLeft())
            fragment.offset(left:most.left)
                    .find("> .interaction > .occurrence")
                    .each (i, occurr) ->
                        occurr = uml(occurr)[0]
                        occurr.move()
                              .prev().offset left:occurr.offset().left
    
    $(".occurrence > .fragment", diag)
        .each(fixwidth)
        .parents(".occurrence > .fragment")
        .each(fixwidth)

align_lifelines_stop_horizontally = (stops) ->
    stops.each (i, e) ->
        e = $(e)
        occurr = e.prev(".occurrence")
        e.offset left:occurr.offset().left

align_creation_message_horizontally = (msgs) ->
    msgs.each (i, e) ->
        $.uml(e)[0]._compose_looks_of_creation()

jQuery.fn.selectWith = (f, cmp) ->
    t = null
    obj = null
    @each (i, e) ->
        if i is 0
            t = f e
            return
        x = f e
        if cmp x, t
            obj = $(e)
            t = x
    t

UMLSequenceDiagram::preferredWidth = () ->
    bw = parseInt(@css "border-right-width") + parseInt(@css "border-left-width")
    
    nodes = $(".object, .ref, .fragment", this)
    return 0 + bw if nodes.length is 0
    a = nodes.mostLeftRight()
    return 0 + bw if a.left is a.right

    f = (e) -> parseInt $(e).css("left")
    cmp = (x, t) -> x < t
    left = nodes.selectWith f, cmp

    #console.log @find(".object .name").css "box-shadow"
    a.right - a.left + bw + 1

jQuery.uml.def ".sequence-diagram", UMLSequenceDiagram


###
This class has information followings:
  - Current diagram instance
  - Current occurrence which is the last occurrence of actor.
###
class JUMLYSequenceDiagramBuilder extends JUMLY.DiagramBuilder
     constructor: (props, @_diagram) ->
        $.extend this, props

JUMLYSequenceDiagramBuilder::_find_or_create_ = (e) ->
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

JUMLYSequenceDiagramBuilder::_actor = -> @_current_occurrence.gives ".object"

JUMLYSequenceDiagramBuilder::message = (a, b, c) ->
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
        console.log "JUMLYSequenceDiagramBuilder::message", msg, a, b, c
        throw msg
        
    iact = @_current_occurrence.interact actee
    iact.name(actname)
        .stereotype(stereotype)

    ## unless callback then return null  ##NOTE: In progress for this spec.
    
    occurr = iact.gives ".actee"
    ctxt = new JUMLYSequenceDiagramBuilder(diagram:@diagram, _current_occurrence:occurr)
    callback?.apply ctxt, []
    ctxt

JUMLYSequenceDiagramBuilder::create = (a, b, c) ->
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
    ctxt = new JUMLYSequenceDiagramBuilder(diagram:@diagram, _current_occurrence:occurr)
    callback?.apply ctxt, []
    ctxt

JUMLYSequenceDiagramBuilder::destroy = (a) ->
    @_current_occurrence.destroy @_find_or_create_ a
    null

JUMLYSequenceDiagramBuilder::reply = (a, b) ->
    @_current_occurrence
        .parents(".interaction:eq(0)").self()
        .reply name:a, ".actee":@_find_or_create_ b
    null

JUMLYSequenceDiagramBuilder::ref = (a) ->
    ($.uml ".ref", a).insertAfter @_current_occurrence.parents(".interaction:eq(0)")
    null

JUMLYSequenceDiagramBuilder::lost = (a) ->
    @_current_occurrence.lost()
    null

## A kind of fragment
JUMLYSequenceDiagramBuilder::loop = (a, b, c) ->
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
JUMLYSequenceDiagramBuilder::alt = (ints, b, c) ->
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
JUMLYSequenceDiagramBuilder::reactivate = (a, b, c) ->
    if a.constructor is this.constructor
        e = a._current_occurrence.parents(".interaction:eq(0)")
        @_actor().activate().append e
        return a

    occurr = @_actor().activate()
    ctxt = new JUMLYSequenceDiagramBuilder(diagram:@diagram, _current_occurrence:occurr)
    ctxt.message(a, b, c)
    ctxt

###
Note on a nearby interaction.
###
JUMLYSequenceDiagramBuilder::note = (a, b, c) ->
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
JUMLYSequenceDiagramBuilder::compose = (opts) ->
    if typeof opts is "function"
        opts @diagram
    else
        opts?.append @diagram
    @diagram.compose opts

JUMLYSequenceDiagramBuilder::preferences = ->
    @diagram.preferences.apply @diagram, arguments

UMLSequenceDiagram::found = (something, callback)->
  diag = this
  ctxt = new JUMLYSequenceDiagramBuilder diagram:diag, diag
  actor = ctxt._find_or_create_ something
  ctxt._current_occurrence = actor.activate()
  ctxt.last = callback?.apply(ctxt, [ctxt])
  ctxt

##
$.jumly.DSL type:'.sequence-diagram', compileScript: (script) ->
    diag = $.jumly '.sequence-diagram'
    diag.found_ = -> eval CoffeeScript.compile script.html()
    diag.found_()
    diag

JUMLY.SequenceDiagramBuilder = JUMLYSequenceDiagramBuilder
