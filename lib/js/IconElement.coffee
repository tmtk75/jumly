self = require: if (typeof module != 'undefined' and typeof module.exports != 'undefined') then require else JUMLY.require
g2d = self.require "jquery.g2d"

_STYLES =
  lineWidth    : 1.5
  fillStyle    : 'white'
  strokeStyle  : 'gray'
  shadowBlur   : 12
  shadowColor  : 'rgba(0,0,0,0.22)' # 'transparent black'
  shadowOffsetX: 8
  shadowOffsetY: 5

Path = g2d.path

_actor = (ctx, styles) ->
  r    = styles.radius || 12
  r2   = r*2
  exth = r*0.25                        # 25% of radius
  lw   = Math.round(styles.lineWidth)  # lw: line-width
  
  # Render a head
  r0 = ->
    ctx.arc lw + r, lw + r, r, 0, Math.PI*2, true
    ctx.fill()
    ctx.shadowColor = 'transparent'
    ctx.stroke()
  
  # Render a body
  r1 = ->
    dh = 3*lw
    dv = r2*0.77
    new Path(ctx)
        .moveTo(0, r2 + lw + exth).line(lw + r2 + lw, 0)  # actor's arms (h-line) 
        .moveTo(lw + r, r2 + lw).line(0, r2*0.35)         # actor's body (v-line)
        .line(-r, dv).move(r, -dv)  # actor's right leg, and back to the groin :)
        .line( r, dv)                     # actor's left leg
    ctx.shadowColor = styles.shadowColor
    ctx.stroke()

  
  ret =
    size:
      width : lw + r2   + lw
      height: lw + r2*2 + lw
    paths: [r0, r1]
          
_view = (ctx, styles) ->
  r    = styles.radius || 16
  r2   = r*2
  extw = r*0.4              # 40% of r
  lw   = styles.lineWidth  # lw: line-width

  r0 = ->
    ctx.arc lw + r + extw, lw + r, r, 0, Math.PI*2, true
    ctx.fill()
    ctx.shadowColor = 'transparent'
    ctx.stroke()
 
  r1 = ->
    new Path(ctx)
        .moveTo(lw, r)
        .line(extw, 0)
        .moveTo(lw, 0)
        .line(0, r2)
    #ctx.shadowColor = styles.shadowColor
    ctx.stroke()

  ret =
    size:
      width :lw + r2 + extw + lw
      height:lw + r2 +        lw
    paths: [r0, r1]

_controller = (ctx, styles) ->
  r    = styles.radius || 16
  r2   = r*2
  exth = r*0.4              # 40% of r
  lw   = lh = styles.lineWidth  # lw: line-width
  dy   = 0
  effectext = 0

  r0 = ->
    ctx.arc lw + r, lw + r + exth, r, 0, Math.PI*2, true
    ctx.fill()
    ctx.shadowColor = 'transparent'
    ctx.stroke()
 
  r1 = ->
    x0 = lw + r*0.8
    x1 = lw + r*1.2
    y0 = lh + exth
    new Path(ctx)
        .moveTo(x0, y0).lineTo(x1, lh + exth/4)
        .moveTo(x0, y0).lineTo(x1, lh + exth*7/4)
    ctx.stroke()

  ret =
    size:
      width :lw + r2 + lw + effectext
      height:lw + r2 + lw + effectext + exth
    paths: [r0, r1]

_entity = (ctx, styles) ->
  r    = styles.radius || 16
  r2   = r*2
  exth = r*0.4             # 40% of r
  lw   = styles.lineWidth  # lw: line-width

  r0 = ->
    ctx.arc lw + r, lw + r, r, 0, Math.PI*2, true
    ctx.fill()
    ctx.shadowColor = 'transparent'
    ctx.stroke()
  
  r1 = ->
    ctx.shadowColor = styles.shadowColor
    new Path(ctx)
        .moveTo(lw + r,  r2)         # v-line (short)
        .lineTo(lw + r,  r2 + exth)  # 
        .moveTo(0,       r2 + exth)  # h-line (long)
        .lineTo(r2 + lw, r2 + exth)  # 
    ctx.stroke()
  
  ret =
    size:
      width :lw + r2 + lw
      height:lw + r2 + exth + lw
    paths: [r0, r1]

_render = (canvas, renderer, args) ->
  return unless canvas.getContext  ## for test on CLI

  styles = $.extend {}, _STYLES, args

  ctx = canvas.getContext '2d'
  {size, paths} = renderer ctx, styles

  dw = (styles.shadowOffsetX || 0) + (styles.shadowBlur/2 || 0)
  dh = (styles.shadowOffsetY || 0) + (styles.shadowBlur/2 || 0)
  $(canvas).attr
    width:size.width + dw, height:size.height + dh
    "data-actual-width":size.width, "data-actual-height":size.height

  $.extend ctx, styles
  #ctx.save()
  #ctx.translate styles.left, styles.top if styles.left or styles.top
  for e in paths
    ctx.beginPath()
    e()
  #ctx.restore()


core = self.require "core"
HTMLElement = self.require "HTMLElement"

class IconElement extends HTMLElement
  @renderer = (type)->
    r =
      actor: _actor
      view: _view
      controller: _controller
      entity: _entity
    (canvas, styles) -> _render canvas, r[type], styles

  constructor: (args, opts)->
    idname = core._normalize args
    super args, (me)->
      canvas = $("<canvas>")
      me.addClass("icon").addClass(opts.kind)
        .append(div = $("<div>").append canvas)
        .append $("<div>").addClass("name").append idname.name
      (IconElement.renderer opts.kind) canvas[0]
      div.css height:canvas.data("actual-height")

if core.env.is_node
  module.exports = IconElement
else
  core.exports IconElement
