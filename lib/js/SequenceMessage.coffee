HTMLElement = require "HTMLElement.coffee"
utils = require "jquery.ext.coffee"

class SequenceMessage extends HTMLElement
  constructor: (@_iact, @_actee)->
    super null, (me)->
      me.append($("<svg class='arrow' width='0' height='0'>"))
        .append($("<div>").addClass "name")

SequenceMessage::_lineToNextOccurr = (svg) ->
  if false #@hasClass("destroy")) {
    ##FIXME: Destroy message
    console.log "FIXME: to avoid runtime error."
    {src:{x:0, y:0}, dst:{x:400, y:0}}
  srcll = @_srcOccurr()
  dstll = @_dstOccurr()
  @_toLine srcll, dstll, svg

SequenceMessage::_toLine = (src, dst, svg) ->
  # Lost message is always toward right.
  e = if !@parent().hasClass("lost") and @isTowardLeft()
    src: x: src.offset().left - @offset().left
    dst: x: dst.outerWidth()
  else
    src: x: src.outerWidth()
    dst: x: dst.offset().left - src.offset().left
  y = svg.outerHeight()/2
  e.src.y = y
  e.dst.y = y
  e

SequenceMessage::_srcOccurr = -> @parents(".occurrence:eq(0)").self()

SequenceMessage::_dstOccurr = -> (if @hasClass "return" then @prev ".occurrence" else $ "~ .occurrence", this).self()

SequenceMessage::_prefferedCanvas = ->
  @find("svg:eq(0)")
    .attr(width:@width(), height:@height())

SequenceMessage::_toCreateLine = (svg)->
  e = @_toLine @_srcOccurr(), @_dstOccurr()._actor, svg
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

to_points = (vals)-> vals.map((e)-> "#{e[0]},#{e[1]}").join " "

_g2d = require "jquery.g2d.coffee"
ahead = (svg, sign, q)->
  dx = sign * 10
  dy = 6
  e = _g2d.svg.new 'polyline', class:"head", points:to_points [[q.x+dx,q.y-dy], [q.x,q.y], [q.x+dx,q.y+dy]]
  svg.appendChild e

  e = _g2d.svg.new 'polyline', class:"closed", points:to_points [[q.x+dx,q.y+(dy+1)], [q.x+dx,q.y-(dy+1)]]
  svg.appendChild e

g2d =
  arrow: (svg, p, q)->
    e = _g2d.svg.new 'line', x1:p.x, y1:p.y, x2:q.x, y2:q.y
    svg[0].appendChild e

    ahead svg[0], -1*(Math.sign q.x - p.x), q

SequenceMessage::repaint = () ->
  shape = STEREOTYPE_STYLES[_determine_primary_stereotype this]
  arrow = jQuery.extend {}, MESSAGE_STYLE, shape
  svg = @_prefferedCanvas()

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
    gap = 2
    rcx = @width() - (gap + 4)
    rey = @height() - (arrow.height/2 + 4)
    llw = @_dstOccurr().outerWidth()
    e = _g2d.svg.new 'polyline', points:to_points [[llw/2 + gap, gap], [rcx, gap], [rcx, rey], [llw + gap,  rey]]
    svg[0].appendChild e

    ahead svg[0], 1, x:llw + gap, y:rey
    return this

  if @hasClass "create"
    line = @_toCreateLine svg
  else if @_actee
    newsrc = @_findOccurr @_actee
    newdst = @_dstOccurr()
    line = @_toLine newsrc, newdst, svg
  else
    line = @_lineToNextOccurr svg
      
  if @hasClass "reverse"
    a           = line.src
    line.src    = line.dst
    line.dst    = a
    arrow.shape = 'dashed'
      
  g2d.arrow svg, line.src, line.dst, arrow
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
    dst.offset top:utils.outerBottom(obj) + mt

  @outerWidth (line_width this) + src.outerWidth() - 1
  shift_downward this

module.exports = SequenceMessage
