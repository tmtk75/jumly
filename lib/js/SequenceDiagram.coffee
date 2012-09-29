HTMLElement = require "HTMLElement"

class JUMLYMessage     extends HTMLElement
class JUMLYInteraction extends HTMLElement
class JUMLYLifeline    extends HTMLElement
class JUMLYOccurrence  extends HTMLElement
class JUMLYFragment    extends HTMLElement
class JUMLYRef         extends HTMLElement
types = 
  ".message"         : JUMLYMessage
  ".interaction"     : JUMLYInteraction
  ".lifeline"        : JUMLYLifeline
  ".occurrence"      : JUMLYOccurrence
  ".fragment"        : JUMLYFragment
  ".ref"             : JUMLYRef
#JUMLY.def e, types[e] for e of types
jumly = $.jumly

JUMLYMessage::_build_ = (div)->
  div.append($("<canvas>").addClass "arrow")
     .append($("<div>").addClass "name")

JUMLYMessage::_lineToNextOccurr = (canvas) ->
  if false #@hasClass("destroy")) {
    ##FIXME: Destroy message
    console.log "FIXME: to avoid runtime error."
    {src:{x:0, y:0}, dst:{x:400, y:0}}
  srcll = @_srcOccurr()
  dstll = @_dstOccurr()
  @_toLine srcll, dstll, canvas

JUMLYMessage::_toLine = (srcll, dstll, canvas) ->
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

JUMLYMessage::_srcOccurr = -> @parents(".occurrence:eq(0)").self()

JUMLYMessage::_dstOccurr = -> (if @hasClass "return" then @prev ".occurrence" else $ "~ .occurrence", this).self()

JUMLYMessage::_prefferedCanvas = ->
  @find("canvas:eq(0)")
    .attr(width:@width(), height:@height())
    .css (width:@width(), height:@height())

JUMLYMessage::_toCreateLine = (canvas)->
  e = @_toLine @_srcOccurr(), @_dstOccurr().gives(".object"), canvas
  if @isTowardLeft()
    src = @_srcOccurr()
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
    return e if jqnode.hasClass e

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
    llw = @_dstOccurr().outerWidth()
    $.g2d.arrow ctxt, {x:rcx, y:rey}, {x:llw + gap,  y:rey}, arrow
    arrow.base = 0
    $.g2d.arrow ctxt, {x:llw/2 + gap, y:gap}, {x:rcx, y:gap}, arrow
    $.g2d.arrow ctxt, {x:rcx,         y:gap}, {x:rcx, y:rey}, arrow
    return this

  if @hasClass "create"
    line = @_toCreateLine canvas
  else if @gives ".actee"
    newsrc = @_findOccurr @gives ".actee"
    newdst = @_dstOccurr()
    line = @_toLine newsrc, newdst, canvas
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
  srcoccur = @_srcOccurr()
  dstoccur = @_dstOccurr()
  render = (msg) ->
    msg.repaint()
     .gives(".interaction").gives(".occurrence").as(".actee")
      
  preffered_width = (msg) ->
    l = msg._toLine srcoccur, dstoccur.gives(".object"), msg
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
  @parents(".sequence-diagram").self()[JUMLY.Naming.toRef objsrc.id] = obj
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


class JUMLYSequenceDiagram extends require("Diagram")
  constructor: ->
    super()
    @append $("<div>").addClass("object-lane")

#JUMLY.def ".sequence-diagram", JUMLYSequenceDiagram
    
JUMLYSequenceDiagram::gives = (query)->
  e = @find(query)
  f = jumly.lang._of e, query
  {of: f}

prefs_ =
    compose_most_left: 0
    WIDTH : null
    HEIGHT: 50
jumly.preferences(".sequence-diagram", prefs_)
jumly.preferences(".sequence-diagram:system-default", prefs_)

JUMLYSequenceDiagram::$ = (sel) -> jumly($(sel, this))
JUMLYSequenceDiagram::$0 = (typesel) -> @$(typesel)[0]
JUMLYSequenceDiagram::preferences = (a, b) ->
    prefs = @jprops().preferences
    if !prefs then @jprops().preferences = prefs = {}
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
    (new JUMLY.SequenceDiagramLayout).layout this
    @trigger "afterCompose", [this]
    this
  catch ex
    causemsg = switch ex.type
                 when "non_object_property_load" then "It may be not loaded completely for DOM tree.\n"
    console.error "JUMLY caught an exception: #{causemsg}", ex.stack, "\n", ex, {arguments:ex.arguments, stack:ex.stack, type:ex.type, message:ex.message, name:ex.name}
    throw ex

JUMLYSequenceDiagram::preferredWidth = () ->
  bw = @css("border-right-width").toInt() + @css("border-left-width").toInt()
  nodes = $(".object, .ref, .fragment", this)
  return 0 + bw if nodes.length is 0
  a = nodes.mostLeftRight()
  return 0 + bw if a.left is a.right
  left = nodes.choose ((e)-> $(e).css("left").toInt()), ((x, t)-> x < t)
  a.right - a.left + bw + 1
