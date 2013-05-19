self = require: if (typeof module != 'undefined' and typeof module.exports != 'undefined') then require else JUMLY.require

_STYLES =
  lineWidth    : 1.5
  fillStyle    : 'white'
  strokeStyle  : 'gray'
  shadowBlur   : 12
  shadowColor  : 'rgba(0,0,0,0.22)' # 'transparent black'
  shadowOffsetX: 8
  shadowOffsetY: 5

## shadow filter
"""
<filter id="dropshadow" width="130%" height="130%">
  <feGaussianBlur in="SourceAlpha" stdDeviation="3"/> <!-- stdDeviation is how much to blur -->
  <feOffset dx="2" dy="2" result="offsetblur"/> <!-- how much to offset -->
  <feMerge> 
    <feMergeNode/> <!-- this contains the offset blurred image -->
    <feMergeNode in="SourceGraphic"/> <!-- this contains the element that the filter is applied to -->
  </feMerge>
</filter>
"""

ns = "http://www.w3.org/2000/svg"

shadow = document.createElementNS ns, "filter"
shadow.setAttribute "id", "dropshadow"
shadow.setAttribute "width", "130%"
#shadow.setAttribute "height", "130%"

blur = document.createElementNS ns, "feGaussianBlur"
blur.setAttribute "in", "SourceAlpha"
blur.setAttribute "stdDeviation", 3

offset = document.createElementNS ns, "feOffset"
offset.setAttribute "dx", 2
offset.setAttribute "dy", 2
offset.setAttribute "result", "offsetblur"

merge = document.createElementNS ns, "feMerge"
merge.appendChild document.createElementNS ns, "feMergeNode"
mergeNode = document.createElementNS ns, "feMergeNode"
mergeNode.setAttribute "in", "SourceGraphic"
merge.appendChild mergeNode

shadow.appendChild blur
shadow.appendChild offset
shadow.appendChild merge


# http://commons.oreilly.com/wiki/index.php/SVG_Essentials/Filters
"""
<filter id="dropshadow">
  <feColorMatrix type="matrix"           [1]
    values=
    "0 0 0 0   0
     0 0 0 0.9 0
     0 0 0 0.9 0
     0 0 0 1   0"/>
  <feGaussianBlur stdDeviation="2.5"     [2]
                  result="coloredBlur"/> [3]
  <feOffset dx="2" dy="2" result="coloreBlur"/>
  <feMerge>                              [4]
    <feMergeNode in="coloredBlur"/>
    <feMergeNode in="SourceGraphic"/>
  </feMerge>
</filter>
"""
ce = (n)-> document.createElementNS ns, n
sa = (n, attrs)->
       for p of attrs
         n.setAttribute p, attrs[p]
       n
ne = (n, attrs)-> sa ce(n), attrs

red = green = blue = 0.22

shadow2 = ne "filter", id:"dropshadow", width:"200%"
matrix  = ne "feColorMatrix", type:"matrix", values:"0 0 0 #{red} 0    0 0 0 #{green} 0    0 0 0 #{blue} 0    0 0 0 1 0"
blur    = ne "feGaussianBlur", stdDeviation:2.5, result:"coloreBlur"
offset  = ne "feOffset", dx:8, dy:5, result:"coloreBlur"
merge   = ne "feMerge"
mnBlur  = ne "feMergeNode", in:"coloreBlur"
mnSrc   = ne "feMergeNode", in:"SourceGraphic"

merge.appendChild mnBlur
merge.appendChild mnSrc

shadow2.appendChild matrix
shadow2.appendChild blur
shadow2.appendChild offset
shadow2.appendChild merge


_actor = (svg, styles) ->
  r    = styles.radius || 12
  r2   = r*2
  exth = r*0.25                        # 25% of radius
  lw   = Math.round(styles.lineWidth)  # lw: line-width
  
  svg.appendChild shadow2

  g = document.createElementNS(ns, 'g')
  g.setAttribute "style", "filter:url(#dropshadow)"
  svg.appendChild g

  # Render a head
  e = document.createElementNS(ns, 'circle')
  e.setAttribute "cx", lw + r
  e.setAttribute "cy", lw + r
  e.setAttribute "r", r
  g.appendChild e
  
  # Render a body
  dh = 3*lw
  dv = r2*0.77
  e = document.createElementNS(ns, 'path')
  d = [
     ["M", 0, r2 + lw + exth]
     ["l", lw + r2 + lw, 0]  # actor's arms (h-line) 
     ["M", lw + r, r2 + lw]
     ["l", 0, r2*0.35]       # actor's body (v-line)
     ["l", -r, dv]
     ["m", r, -dv]           # actor's right leg, and back to the groin :)
     ["l", r,  dv]           # actor's left leg
    ]
  to_d = (d)-> (d.map (e)-> "#{e[0]}#{e[1]},#{e[2]}").join ""
  e.setAttribute "d", to_d d
  g.appendChild e

  ret =
    size:
      width : lw + r2   + lw
      height: lw + r2*2 + lw
          
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

_render = (svg, renderer, args) ->
  #return unless svg.getContext  ## for test on CLI

  styles = $.extend {}, _STYLES, args

  {size, paths} = renderer svg, styles

  dw = (styles.shadowOffsetX || 0) + (styles.shadowBlur/2 || 0)
  dh = (styles.shadowOffsetY || 0) + (styles.shadowBlur/2 || 0)
  $(svg).attr
    width:size.width + dw, height:size.height + dh
    "data-actual-width":size.width, "data-actual-height":size.height

core = self.require "core"
HTMLElement = self.require "HTMLElement"

class IconElement extends HTMLElement
  @renderer = (type)->
    r =
      actor: _actor
      view: _view
      controller: _controller
      entity: _entity
    (svg, styles) -> _render svg, r[type], styles

  constructor: (args, opts)->
    idname = core._normalize args
    super args, (me)->
      svg = $("<svg width='0' height='0'>")
      me.addClass("icon").addClass(opts.kind)
        .append(div = $("<div>").append svg)
        .append $("<div>").addClass("name").append idname.name
      (IconElement.renderer opts.kind) svg[0]
      div.css height:svg.data("actual-height")

if core.env.is_node
  module.exports = IconElement
else
  core.exports IconElement
