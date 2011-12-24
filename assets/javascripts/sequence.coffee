class JUMLYMessage extends JUMLY.HTMLElement
class JUMLYInteraction extends JUMLY.HTMLElement
class JUMLYLifeline extends JUMLY.HTMLElement
class JUMLYOccurrence extends JUMLY.HTMLElement
class JUMLYFragment extends JUMLY.HTMLElement
class JUMLYSequenceDiagram extends JUMLY.Diagram
class JUMLYRef extends JUMLY.HTMLElement
jumly = $.jumly
jumly.def ".message", JUMLYMessage
jumly.def ".interaction", JUMLYInteraction
jumly.def ".lifeline", JUMLYLifeline
jumly.def ".occurrence", JUMLYOccurrence
jumly.def ".fragment", JUMLYFragment
jumly.def ".ref", JUMLYRef
jumly.def ".sequence-diagram", JUMLYSequenceDiagram

JUMLYMessage::_build_ = (div)->
  div.append($("<canvas>").addClass "arrow")
     .append($("<div>").addClass "name")

JUMLYMessage::to_line = (canvas) ->  # For backward compatibility.
  @_lineToNextOccurr canvas

JUMLYMessage::_lineToNextOccurr = (canvas) ->
  if false #@hasClass("destroy")) {
    ##FIXME: Destroy message
    console.log "FIXME: to avoid runtime error."
    {src:{x:0, y:0}, dst:{x:400, y:0}}
  srcll = @_src_occurr()
  dstll = @_dst_occurr()
  @_to_line srcll, dstll, canvas

JUMLYMessage::_to_line = (srcll, dstll, canvas) ->
  # Lost message is always toward right.
  if !@parent().hasClass("lost") and @isTowardLeft()
    src:
      x: srcll.offset().left - @offset().left
      y: canvas.outerHeight()/2
    dst:
      x: dstll.outerWidth()
      y: canvas.outerHeight()/2
  else
    src:
      x: srcll.outerWidth()
      y: canvas.outerHeight()/2
    dst:
      x: dstll.offset().left - srcll.offset().left
      y: canvas.outerHeight()/2

JUMLYMessage::_src_occurr = -> @parents(".occurrence:eq(0)").self()

JUMLYMessage::_dst_occurr = -> (if @hasClass "return" then @prev ".occurrence" else $ "~ .occurrence", this).self()

JUMLYMessage::_prefferedCanvas = ->
  @find("canvas:eq(0)")
    .attr(width:@width(), height:@height())
    .css (width:@width(), height:@height())

JUMLYMessage::_to_create_line = (canvas)->
  e = @_to_line @_src_occurr(), @_dst_occurr().gives(".object"), canvas
  if @isTowardLeft()
    src = @_src_occurr()
    e.dst.x = src.gives(".object").outerRight() - src.offset().left
  e

JUMLYMessage::_findOccurr = (actee)->
  occurr = null
  @parents(".occurrence").each (i, e)=>
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

JUMLYMessage::repaint = (style) ->
  arrow = jQuery.extend {}, MESSAGE_STYLE, style, STEREOTYPE_STYLES[_determine_primary_stereotype this]
  # Canvas element has width x height property of CSS and posseses width x height attribute as DOM element.
  # So if you don't set same value to both, the rendered result may be inconsistent.
  canvas = @_current_canvas = @_prefferedCanvas()

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
    llw = @_dst_occurr().outerWidth()
    $.g2d.arrow ctxt, {x:rcx, y:rey}, {x:llw + gap,  y:rey}, arrow
    arrow.base = 0
    $.g2d.arrow ctxt, {x:llw/2 + gap, y:gap}, {x:rcx, y:gap}, arrow
    $.g2d.arrow ctxt, {x:rcx,         y:gap}, {x:rcx, y:rey}, arrow
    return this

  if @hasClass "create"
    line = @_to_create_line canvas
  else if @gives ".actee"
    newsrc = @_findOccurr @gives ".actee"
    newdst = @_dst_occurr()
    line = @_to_line newsrc, newdst, canvas
  else
    line = @_lineToNextOccurr canvas
      
  if arrow.reverse
    a           = line.src
    line.src    = line.dst
    line.dst    = a
    arrow.shape = 'dashed'
      
  jQuery.g2d.arrow canvas[0].getContext('2d'), line.src, line.dst, arrow
  this

JUMLYMessage::isToward = (dir) ->
  iact = @gives(".interaction")
  see = (a)-> iact.gives(".occurrence").as(a).gives(".object")
  actor = see ".actor"
  actee = see ".actee"
  if "right" is dir
    actor.isLeftAt(actee)
  else if "left" is dir
    actor.isRightAt(actee)

JUMLYMessage::isTowardRight = -> @isToward "right"

JUMLYMessage::isTowardLeft = -> @isToward "left"

JUMLYMessage::_composeLooksOfCreation = ->
  srcoccur = @_src_occurr()
  dstoccur = @_dst_occurr()
  render = (msg) ->
    msg.repaint()
     .gives(".interaction").gives(".occurrence").as(".actee")
      
  preffered_width = (msg) ->
    l = msg._to_line srcoccur, dstoccur.gives(".object"), msg
    Math.abs l.src.x - l.dst.x
      
  centering_name = (msg, newwidth) ->
    return if msg.isTowardLeft()
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
    iact = msg.parents(".interaction:eq(0)")
    dy = iact.outerBottom() - dstoccur.outerBottom() - parseInt dstoccur.css "margin-top"
    iact.css "margin-bottom", (Math.abs dy) 
  
  created = dstoccur.gives ".object"
  w = preffered_width this
  shift_downward this
  render this
  centering_name this, w
  shift_down_lifeline created

JUMLYInteraction::_build_ = (div, props)->
  msg = jumly type:".message", ".interaction":this
  props[".message"] = msg  ## FIXME: Can I remove this?
  div.append(msg)

JUMLYInteraction::interact = (obj) -> @awayfrom().interact obj
JUMLYInteraction::forward = (obj) -> @toward()

JUMLYInteraction::to = (func) ->
  occurrs = @gives(".occurrence")
  tee = occurrs.as(".actee")
  tor = occurrs.as(".actor")
  func(tee, tor)

JUMLYInteraction::forwardTo = -> @gives(".occurrence").as ".actee"
JUMLYInteraction::backwardTo = -> @gives(".occurrence").as ".actor"
JUMLYInteraction::toward = -> @forwardTo()
JUMLYInteraction::awayfrom = (obj) ->
  return @backwardTo() unless obj
  for e in @parents(".occurrence").not(".activated")
    e = $(e).self()
    return e if e?.gives(".object") is obj
  obj.activate()

JUMLYInteraction::_compose_ = ->
  that = this
  src = that.gives(".occurrence").as ".actor"
  dst = that.gives(".occurrence").as ".actee"
  msg = jumly($ "> .message", that)[0]
  # Self-invokation case
  if @isToSelf()
    @_buildSelfInvocation src, dst, msg
    return

  # Determine the width of interaction for normal message
  w = src.offset().left - (dst.offset().left + $(".occurrence:eq(0)", that).width())
  if @hasClass("lost")
    msg.height dst.outerHeight()
  else if msg.isTowardLeft()
    w = dst.offset().left - (src.offset().left + $(".occurrence:eq(0)", that).width())
  msg.width(Math.abs(w))
     .offset(left:Math.min(src.offset().left, dst.offset().left))
     .repaint()

  # Locate the name of message
  # Normal message
  #TODO: Move this centering logic for name to .message class. 

  # Return message
  rmsg = $("> .message.return:last", that).self()
  if rmsg
    x = msg.offset().left
    actee = rmsg.gives ".actee"
    if actee
      newdst = rmsg._findOccurr actee
      unless newdst
        console.error "Not found occurrence for", actee
        throw new Error("Not found occurrence #{actee.html()}")
      w = dst.offset().left - newdst.offset().left
      x = Math.min dst.offset().left, newdst.offset().left
    rmsg.width(Math.abs w)
        .offset(left:x)
        .repaint(reverse:true)

JUMLYInteraction::_buildSelfInvocation = (a, b, msg) ->
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

JUMLYInteraction::reply = (p) ->
    @addClass "reply"
    a = jumly(type:".message", ".interaction":this, ".actee":p?[".actee"]).addClass("return")
        .insertAfter @children ".occurrence:eq(0)"
    if p?.name
        a.name p.name
    this

JUMLYInteraction::fragment = (attrs, opts) ->
    frag = jumly(type:".fragment")
    frag.enclose(this)
   
JUMLYInteraction::isToSelf = ->
    a = @gives(".occurrence").as ".actor"
    b = @gives(".occurrence").as ".actee"
    unless a && b
        return false
    a.gives(".object") is b.gives(".object")

JUMLYInteraction::is_to_itself = -> @isToSelf()

JUMLYLifeline::_build_ = (div, props)->
  div.append($("<div>").addClass("line").height(128))
	   .width(props[".object"].width())
	   .height(128)

JUMLYOccurrence::interact = (_, opts) ->
    _as = jumly.lang._as
    if opts?.stereotype is ".lost"
        occurr = jumly(type:".occurrence").addClass "icon"
        iact   = jumly type:".interaction", ".occurrence":_as(".actor":this, ".actee":occurr), ".actor":this, ".actee":occurr
        iact.addClass "lost"
    else if opts?.stereotype is ".destroy"
        #NOTE: Destroy message building
    else if _?.stereotype is ".alt"
        alt = jumly ".fragment", name:"alt"
        alt.alter this, opts
        return this
    else
        occurr = jumly type:".occurrence", ".object":_
        iact   = jumly
                    "type"       : ".interaction"
                    ".occurrence": _as(".actor":this, ".actee":occurr)
                    ".object"    : _as(".actor":@gives(".object"), ".actee":_)
                    ".actor"     : this
                    ".actee"     : occurr
    iact.append(occurr).appendTo this
    iact

JUMLYOccurrence::create = (objsrc) ->
  obj = jumly ".object", objsrc.name
  obj.attr "id", objsrc.id
  @parents(".sequence-diagram").self()[objsrc.id] = obj
  @gives(".object").parent().append obj
  iact = (@interact obj).stereotype "create"
  iact

JUMLYOccurrence::moveHorizontally =->
  if @parent().hasClass "lost"
    @offset left:@parents(".diagram").find(".object").mostLeftRight().right
    return this 
  if not @isOnOccurrence()
    left = @gives(".object").offset().left + (@gives(".object").width() - @width())/2
  else
    left = @parentOccurrence().offset().left
  left += @width()*@shiftToParent()/2
  @offset left:left

JUMLYOccurrence::isOnOccurrence =-> not (@parentOccurrence() is null)

JUMLYOccurrence::parentOccurrence = ->
    lls = jumly(@parents(".occurrence"))
    return null if lls.length is 0

    for i in [0..lls.length - 1]
        if @gives(".object") is lls[i].gives(".object")
            return lls[i]
    null

JUMLYOccurrence::shiftToParent = ->
    return 0 if not @isOnOccurrence()
    # find a message contained in the same interaction together.
    a = jumly(@parent().find ".message:eq(0)")[0]
    return 0  if a is undefined
    return -1 if a.isTowardRight()
    return 1  if a.isTowardLeft()
    # in case of self-invokation below
    return 1

JUMLYOccurrence::preceding = (obj) ->
    f = (ll) ->
        a = jumly(ll.parents ".occurrence:eq(0)")[0]
        return null if !a
        return a    if a.gives(".object") is obj
        return f a
    f this

JUMLYOccurrence::destroy = (actee) ->
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

JUMLYFragment::_build_ = (div)->
  div.append($("<div>").addClass("header")
                       .append($("<div>").addClass("name"))
                       .append($("<div>").addClass("condition")))

JUMLYFragment::enclose = (_) ->
    if not _? or _.length is 0
        throw "JUMLYFragment::enclose arguments are empty."
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

JUMLYFragment::extendWidth = (opts) ->
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
JUMLYFragment::alter = (occurr, opts) ->
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

JUMLYRef::_build_ = (div)->
  div.append($("<div>").addClass("header")
                       .append($("<div>").addClass("tag")
                                         .html "ref"))
     .append $("<div>").addClass "name"

# preferredWidth
JUMLYRef::preferredWidth = ->
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
    
JUMLYSequenceDiagram::gives = (query)->
  e = @find(query)
  f = jumly.lang._of e, query
  {of: f}

prefs_ =
    compose_most_left: 0
    compose_span     : 150 - (88 + 4)
    WIDTH : null
    HEIGHT: 50
jumly.preferences(".sequence-diagram", prefs_)
jumly.preferences(".sequence-diagram:system-default", prefs_)

JUMLYSequenceDiagram::$ = (sel) -> jumly($(sel, this))
JUMLYSequenceDiagram::$0 = (typesel) -> @$(typesel)[0]
JUMLYSequenceDiagram::preferences = (a, b) ->
    prefs = @data("uml:property").preferences
    if !prefs then @data("uml:property").preferences = prefs = {}
    width = ->
        objs  = $(".object", this)
        left  = objs.min((e) -> $(e).position().left) - @position().left
        right = objs.max((e) -> $(e).position().left + $(e).outerWidth()) - @position().left
        left + (right - left) + left
    ## Return preferences
    if (!b and typeof a is "string") or (!a and !b)
        r = $.extend {}, jumly.preferences(".sequence-diagram"), prefs
        r.WIDTH = width.apply this
        return r
    ## Overrite instance preferences
    #console.log "setter", prefs
    $.extend prefs, a

JUMLYSequenceDiagram::compose = (props) ->
  try
    @trigger "beforeCompose", [this]
    (new SequenceDiagramLayout).layout this
    @trigger "afterCompose", [this]
    this
  catch ex
    causemsg = switch ex.type
                 when "non_object_property_load" then "It may be not loaded completely for DOM tree.\n"
    console.error "JUMLY caught an exception: #{causemsg}", ex.stack, "\n", ex, {arguments:ex.arguments, stack:ex.stack, type:ex.type, message:ex.message, name:ex.name}
    throw ex

class SequenceDiagramLayout extends JUMLY.DiagramLayout

SequenceDiagramLayout::_layout_ = ->
  @align_objects_horizontally()
  @align_occurrences_horizontally()
  @compose_interactions()
  @generate_lifelines_and_align_horizontally()
  @pack_object_lane_vertically()
  @pack_refs_horizontally()
  @pack_fragments_horizontally()
  @align_creation_message_horizontally()
  @align_lifelines_vertically()
  @align_lifelines_stop_horizontally()
  @rebuild_asynchronous_self_calling()
  @render_icons()
  @diagram.width @diagram.preferredWidth()
  
SequenceDiagramLayout::align_objects_horizontally = ->
  f0 = (a)=>
    if a.css("left") is "auto"
      a.css left:@prefs.compose_most_left
  f1 = (a, b)=>
    if b.css("left") is "auto"
      l = a.position().left + a.outerWidth() + @prefs.compose_span
      b.css left:l
  @_q(".object").pickup2 f0, f1

SequenceDiagramLayout::align_occurrences_horizontally = ->
   @_q(".occurrence").selfEach (e)-> e.moveHorizontally()

SequenceDiagramLayout::compose_interactions = ->
  @_q(".occurrence .interaction").selfEach (e)-> e._compose_()

SequenceDiagramLayout::generate_lifelines_and_align_horizontally = ->
  @_q(".lifeline").remove()
  @_q(".object").selfEach (obj)->
    a = jumly type:".lifeline", ".object":obj
    a.offset left:obj.offset().left, top:obj.outerBottom() + 1
    a.insertAfter obj

SequenceDiagramLayout::pack_object_lane_vertically = ()->
  return if @_q(".object-lane").length > 0
  objs = @_q(".object")
  mostheight = jQuery.max objs, (e) -> $(e).outerHeight()
  mostheight ?= 0
  $("<div>").addClass("object-lane")
            .height(mostheight)
            .swallow(objs)

SequenceDiagramLayout::pack_refs_horizontally = ->
  refs = @_q(".ref")
  return if refs.length is 0
  $(refs).selfEach (ref) ->
    pw = ref.preferredWidth()
    ref.offset(left:pw.left)
       .width(pw.width)

SequenceDiagramLayout::pack_fragments_horizontally = ->
  # fragments just under this diagram.
  fragments = $ "> .fragment", @diagram
  if fragments.length > 0
    # To controll the width, you can write selector below.
    # ".object:eq(0), > .interaction > .occurrence .interaction"
    most = @_q(".object").mostLeftRight()
    left = fragments.offset().left
    fragments.width (most.right - left) + (most.left - left)
  
  # fragments inside diagram
  fixwidth = (fragment) ->
    most = $(".occurrence, .message, .fragment", fragment).not(".return, .lost").mostLeftRight()
    fragment.width(most.width() - (fragment.outerWidth() - fragment.width()))
    ## WORKAROUND: it's tentative for both of next condition and the body
    msg = jumly(fragment.find("> .interaction > .message"))[0]
    if (msg?.isTowardLeft())
      fragment.offset(left:most.left)
              .find("> .interaction > .occurrence")
              .each (i, occurr) ->
                occurr = jumly(occurr)[0]
                occurr.moveHorizontally()
                      .prev().offset left:occurr.offset().left
  
  @_q(".occurrence > .fragment")
    .selfEach(fixwidth)
    .parents(".occurrence > .fragment")
    .each(fixwidth)

SequenceDiagramLayout::align_lifelines_vertically = ->
  mostbottom = @diagram.find(".occurrence")
                       .not(".interaction.lost .occurrence")
                       .max (e) -> $(e).outerBottom()
  @_q(".lifeline").selfEach (a) ->
    obj = a.gives(".object")
    y = obj.outerBottom() + 1
    a.offset left:obj.offset().left, top:y
    h = mostbottom - y + 16
    a.height h
    a.find(".line").css(top:0).height h

SequenceDiagramLayout::align_lifelines_stop_horizontally = ->
  $(".stop", @diagram).each (i, e) ->
    e = $(e)
    occurr = e.prev(".occurrence")
    e.offset left:occurr.offset().left

SequenceDiagramLayout::align_creation_message_horizontally = ->
  @_q(".message.create").selfEach (e)->
    e._composeLooksOfCreation()

SequenceDiagramLayout::rebuild_asynchronous_self_calling = ->
  @diagram.find(".message.asynchronous").parents(".interaction:eq(0)").each (i, e) ->
    e = $(e).self()
    if not e.isToSelf()
        return
    iact = e.addClass("activated")
            .addClass("asynchronous")
    prev = iact.parents(".interaction:eq(0)")
    iact.insertAfter prev
    
    occurr = iact.css("padding-bottom", 0)
                 .find("> .occurrence").self()
                 .moveHorizontally()
                 .css("top", 0)

    msg = iact.find(".message").self()
    msg.css("z-index", -1)
       .offset
         left: occurr.offset().left
         top : prev.find(".occurrence").outerBottom() - msg.height()/3

SequenceDiagramLayout::render_icons = ->
  @_q(".object").selfEach (e)-> e.renderIcon?()

JUMLYSequenceDiagram::preferredWidth = () ->
  bw = @css("border-right-width").toInt() + @css("border-left-width").toInt()
  nodes = $(".object, .ref, .fragment", this)
  return 0 + bw if nodes.length is 0
  a = nodes.mostLeftRight()
  return 0 + bw if a.left is a.right
  left = nodes.choose ((e)-> $(e).cssLeft()), ((x, t)-> x < t)
  a.right - a.left + bw + 1

class JUMLYSequenceDiagramBuilder extends JUMLY.DiagramBuilder
  constructor: (props, @_diagram) ->
    $.extend this, props

JUMLYSequenceDiagramBuilder::_findOrCreate = (e) ->
  switch typeof e
    when "string"
      if @diagram[e]
        return @diagram[e]
      a = JUMLY.Identity.normalize e
      obj = jumly ".object", a
      @diagram._regByRef_ a.id, obj
      @diagram.append obj
      obj
    when "object"
      a = JUMLY.Identity.normalize e
      obj = jumly ".object", a
      @diagram._regByRef_ a.id, obj
      @diagram.append obj
      obj

JUMLYSequenceDiagramBuilder::_actor = -> @_currOccurr.gives ".object"

JUMLYSequenceDiagramBuilder::message = (a, b, c) ->
  actname  = a
  if typeof b is "function" or b is undefined
    actee = @_actor()
    callback = b
  else if typeof a is "string" and typeof b is "string"
    if typeof c is "function"
      actee = @_findOrCreate b
      callback = c
    else if c is undefined
      actee = @_findOrCreate b
      callback = null
  else if typeof a is "object" and typeof b is "string"
    actee = @_findOrCreate b
    callback = c
    for e of a
      switch e
        when "asynchronous"
          actname = a[e]
          stereotype = "asynchronous" 
  else if typeof a is "string" and typeof b is "object"
    norm = JUMLY.Identity.normalize b
    actee = @_findOrCreate norm.name
    callback = c
  else
    msg = "invalid arguments"
    console.error "JUMLYSequenceDiagramBuilder::message", msg, a, b, c
    throw new Error(msg, a, b, c)
      
  iact = @_currOccurr.interact actee
  iact.name(actname)
      .stereotype(stereotype)
  ## unless callback then return null  ##NOTE: In progress for this spec.
  occurr = iact.gives ".actee"
  b = new JUMLYSequenceDiagramBuilder(diagram:@diagram, _currOccurr:occurr)
  callback?.apply b, []
  b

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
  else if typeof a is "object" and typeof b is "function"
    e = JUMLY.Identity.normalize a
    actee    = e.name
    callback = b
      
  id = JUMLY.Naming.toID(actee)
  iact = @_currOccurr.create id:id, name:actee
  iact.name name if name 
  ## unless callback then return null  ##NOTE: In progress for this spec.
  occurr = iact.gives ".actee"
  ctxt = new JUMLYSequenceDiagramBuilder(diagram:@diagram, _currOccurr:occurr)
  callback?.apply ctxt, []
  ctxt

JUMLYSequenceDiagramBuilder::destroy = (a) ->
  @_currOccurr.destroy @_findOrCreate a
  null

JUMLYSequenceDiagramBuilder::reply = (a, b) ->
  obj = b
  if typeof b is "string"
    ref = JUMLY.Naming.toRef JUMLY.Naming.toID(b)
    obj = @diagram[ref] if @diagram[ref]
  @_currOccurr
    .parents(".interaction:eq(0)").self()
    .reply name:a, ".actee":obj
  null

JUMLYSequenceDiagramBuilder::ref = (a) ->
  (jumly ".ref", a).insertAfter @_currOccurr.parents(".interaction:eq(0)")
  null

JUMLYSequenceDiagramBuilder::lost = (a) ->
  @_currOccurr.lost()
  null

## A kind of fragment
JUMLYSequenceDiagramBuilder::loop = (a, b, c) ->
  ## NOTE: Should this return null in case of no context
  if a.constructor is this.constructor  ## First one is DSL
    frag = a._currOccurr
     .parents(".interaction:eq(0)").self()
     .fragment(name:"Loop")
     .addClass "loop"
  else
    last = [].slice.apply(arguments).pop()  ## Last one is Function
    if $.isFunction(last)
      kids = @_currOccurr.find("> *")
      last.apply this, []
      newones = @_currOccurr.find("> *").not(kids)
      if newones.length > 0
        frag = jumly(".fragment").addClass("loop").enclose newones
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
      what._currOccurr
          .parent(".interaction:eq(0)")
    iacts[name] = _new_act(name, act)
  @_currOccurr.interact stereotype:".alt", iacts
  this

###
Examples:
  - @reactivate "do something", "A"
  - @reactivate @message "call a taxi", "Taxi agent"
###
JUMLYSequenceDiagramBuilder::reactivate = (a, b, c) ->
  if a.constructor is this.constructor
    e = a._currOccurr.parents(".interaction:eq(0)")
    @_actor().activate().append e
    return a
  occurr = @_actor().activate()
  ctxt = new JUMLYSequenceDiagramBuilder(diagram:@diagram, _currOccurr:occurr)
  ctxt.message(a, b, c)
  ctxt

JUMLYSequenceDiagramBuilder::note = (a, b, c) ->
  nodes = @_currOccurr.find("> .interaction:eq(0)")
  if nodes.length is 0
    nodes = @_currOccurr.parents ".interaction:eq(0):not(.activated)"

  ##TENTATIVE: because DSL notation is not decided.
  text = a
  opts = b
  note = jumly ".note", text
  if opts
    note.attach nodes, opts
  else
    nodes.append note

JUMLYSequenceDiagramBuilder::found = (something, callback)->
  actor = @_findOrCreate something
  @_currOccurr = actor.activate()
  @last = callback?.apply this, [this]
  this

JUMLYSequenceDiagramBuilder::compose = (opts) ->
  if typeof opts is "function"
    opts @diagram
  else
    opts?.append @diagram
  @diagram.compose opts

JUMLYSequenceDiagramBuilder::preferences = ->
  @diagram.preferences.apply @diagram, arguments

##NOTE: Keep compatibility to 0.1.0
JUMLYSequenceDiagram::found = (something, callback)->
  b = new JUMLYSequenceDiagramBuilder
  b.diagram = this
  b.found something, callback
  
JUMLYSequenceDiagramBuilder::beforeCompose = (f)->
  @diagram.bind "beforeCompose", f
  this
JUMLYSequenceDiagramBuilder::afterCompose = (f)->
  @diagram.bind "afterCompose", f
  this
  
##
jumly.DSL type:'.sequence-diagram', compileScript: (script) ->
  b = new JUMLYSequenceDiagramBuilder
  b.build script.html()

JUMLY.SequenceDiagramBuilder = JUMLYSequenceDiagramBuilder
