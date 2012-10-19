HTMLElement = require "HTMLElement"

class SequenceMessage extends HTMLElement
  constructor: (@_iact, @_actee)->
    super()

SequenceMessage::_build_ = (div)->
  div.append($("<canvas>").addClass "arrow")
     .append($("<div>").addClass "name")

SequenceMessage::_lineToNextOccurr = (canvas) ->
  if false #@hasClass("destroy")) {
    ##FIXME: Destroy message
    console.log "FIXME: to avoid runtime error."
    {src:{x:0, y:0}, dst:{x:400, y:0}}
  srcll = @_srcOccurr()
  dstll = @_dstOccurr()
  @_toLine srcll, dstll, canvas

SequenceMessage::_toLine = (srcll, dstll, canvas) ->
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

SequenceMessage::_srcOccurr = -> @parents(".occurrence:eq(0)").self()

SequenceMessage::_dstOccurr = -> (if @hasClass "return" then @prev ".occurrence" else $ "~ .occurrence", this).self()

SequenceMessage::_prefferedCanvas = ->
  @find("canvas:eq(0)")
    .attr(width:@width(), height:@height())
    .css (width:@width(), height:@height())

SequenceMessage::_toCreateLine = (canvas)->
  e = @_toLine @_srcOccurr(), @_dstOccurr().gives(".object"), canvas
  if @isTowardLeft()
    src = @_srcOccurr()
    e.dst.x = src.gives(".object").outerRight() - src.offset().left
  e

SequenceMessage::_findOccurr = (actee)->
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

SequenceMessage::repaint = (style) ->
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

SequenceMessage::isToward = (dir) ->
  actor = @_iact._actor._actor
  actee = @_iact._actee._actor
  if "right" is dir
    actor.isLeftAt(actee)
  else if "left" is dir
    actor.isRightAt(actee)

SequenceMessage::isTowardRight = ->
  @isToward "right"

SequenceMessage::isTowardLeft = ->
  @isToward "left"

SequenceMessage::_composeLooksOfCreation = ->
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

core = require "core"
if core.env.is_node
  module.exports = SequenceMessage
else
  core.exports SequenceMessage
