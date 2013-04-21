self = require: if (typeof module != 'undefined' and typeof module.exports != 'undefined') then require else JUMLY.require
HTMLElement = self.require "HTMLElement"
g2d = self.require "jquery.g2d"

class SequenceMessage extends HTMLElement
  constructor: (@_iact, @_actee)->
    super null, (me)->
      me.append($("<canvas>").addClass "arrow")
        .append($("<div>").addClass "name")

SequenceMessage::_lineToNextOccurr = (canvas) ->
  if false #@hasClass("destroy")) {
    ##FIXME: Destroy message
    console.log "FIXME: to avoid runtime error."
    {src:{x:0, y:0}, dst:{x:400, y:0}}
  srcll = @_srcOccurr()
  dstll = @_dstOccurr()
  @_toLine srcll, dstll, canvas

SequenceMessage::_toLine = (src, dst, canvas) ->
  # Lost message is always toward right.
  e = if !@parent().hasClass("lost") and @isTowardLeft()
    src: x: src.offset().left - @offset().left
    dst: x: dst.outerWidth()
  else
    src: x: src.outerWidth()
    dst: x: dst.offset().left - src.offset().left
  y = canvas.outerHeight()/2
  e.src.y = y
  e.dst.y = y
  e

SequenceMessage::_srcOccurr = -> @parents(".occurrence:eq(0)").self()

SequenceMessage::_dstOccurr = -> (if @hasClass "return" then @prev ".occurrence" else $ "~ .occurrence", this).self()

SequenceMessage::_prefferedCanvas = ->
  @find("canvas:eq(0)")
    .attr(width:@width(), height:@height())
    .css (width:@width(), height:@height())

SequenceMessage::_toCreateLine = (canvas)->
  e = @_toLine @_srcOccurr(), @_dstOccurr()._actor, canvas
  if @isTowardLeft()
    src = @_srcOccurr()
    outerRight = (it)-> it.offset().left + it.outerWidth()
    e.dst.x = outerRight(src._actor) - src.offset().left
  e

SequenceMessage::_findOccurr = (actee)->
  occurr = null
  @parents(".occurrence").each (i, e)=>
    e = $(e).data "_self"
    if e._actor is actee
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

SequenceMessage::repaint = () ->
  shape = STEREOTYPE_STYLES[_determine_primary_stereotype this]
  arrow = jQuery.extend {}, MESSAGE_STYLE, shape
  # Canvas element has width x height property of CSS and posseses width x height attribute as DOM element.
  # So if you don't set same value to both, the rendered result may be inconsistent.
  canvas = @_current_canvas = @_prefferedCanvas()

  if false
    p = @parents(".occurrence:eq(0)")
    arrow.fillStyle   = p.css "background-color"
    arrow.strokeStyle = p.css "border-top-color"
    (p.css "box-shadow").match /(rgba\(.*\)) ([0-9]+)px ([0-9]+)px ([0-9]+)px ([0-9]+)px/
    arrow.shadowColor   = RegExp.$1
    arrow.shadowOffsetX = RegExp.$2
    arrow.shadowOffsetY = RegExp.$3
    arrow.shadowBlur    = RegExp.$4

  if @hasClass "self"
    ctxt = canvas[0].getContext '2d'
    gap = 2
    rcx = @width() - (gap + 4)
    rey = @height() - (arrow.height/2 + 4)
    llw = @_dstOccurr().outerWidth()
    g2d.arrow ctxt, {x:rcx, y:rey}, {x:llw + gap,  y:rey}, arrow
    arrow.base = 0
    g2d.arrow ctxt, {x:llw/2 + gap, y:gap}, {x:rcx, y:gap}, arrow
    g2d.arrow ctxt, {x:rcx,         y:gap}, {x:rcx, y:rey}, arrow
    return this

  if @hasClass "create"
    line = @_toCreateLine canvas
  else if @_actee
    newsrc = @_findOccurr @_actee
    newdst = @_dstOccurr()
    line = @_toLine newsrc, newdst, canvas
  else
    line = @_lineToNextOccurr canvas
      
  if @hasClass "reverse"
    a           = line.src
    line.src    = line.dst
    line.dst    = a
    arrow.shape = 'dashed'
      
  g2d.arrow canvas[0].getContext('2d'), line.src, line.dst, arrow
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

SequenceMessage::_to_be_creation = ->
  src = @_srcOccurr()
  dst = @_dstOccurr()
      
  line_width = (msg) ->
    l = msg._toLine src, dst._actor, msg
    Math.abs l.src.x - l.dst.x
      
  shift_downward = (msg) ->
    obj = dst._actor
    obj.offset top:msg.offset().top - obj.height()/3
    mt = parseInt dst.css "margin-top"
    dst.offset top:obj.outerBottom() + mt

  @outerWidth (line_width this) + src.outerWidth() - 1
  shift_downward this

core = self.require "core"
if core.env.is_node
  module.exports = SequenceMessage
else
  core.exports SequenceMessage
