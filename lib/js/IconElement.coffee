_STYLES =
  lineWidth    : 1.5
  fillStyle    : 'white'
  strokeStyle  : 'gray'
  shadowBlur   : 12
  shadowColor  : 'rgba(0,0,0,0.22)' # 'transparent black'
  shadowOffsetX: 8
  shadowOffsetY: 5

ns = "http://www.w3.org/2000/svg"

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
g2d = self.require "jquery.g2d"
ce = g2d.svg.create
sa = g2d.svg.attrs
ne = (n, attrs)-> sa ce(n), attrs

red = green = blue = 0.22*3

drop_shadow = ->
  shadow2 = ne "filter", id:"dropshadow", width:"200%", height:"200%"
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
  shadow2

to_d = (d)-> (d.map (e)-> "#{e[0]}#{e[1]},#{e[2]}").join ""

svg_g = (svg)->
  svg.appendChild drop_shadow()
  g = sa (ce 'g'), style:"filter:url(#dropshadow)"
  svg.appendChild g
  g

_actor = (svg, styles) ->
  r    = styles.radius || 12
  r2   = r*2
  exth = r*0.25                        # 25% of radius
  lw   = Math.round(styles.lineWidth)  # lw: line-width

  g = svg_g svg

  # Render a head
  g.appendChild ne 'circle', cx:lw + r, cy:lw + r, r:r
  
  # Render a body
  dh = 3*lw
  dv = r2*0.77
  d = [
     ["M", 0, r2 + lw + exth]
     ["l", lw + r2 + lw, 0]  # actor's arms (h-line) 
     ["M", lw + r, r2 + lw]
     ["l", 0, r2*0.35]       # actor's body (v-line)
     ["l", -r, dv]
     ["m", r, -dv]           # actor's right leg, and back to the groin :)
     ["l", r,  dv]           # actor's left leg
    ]
  e = ne 'path', d:to_d d
  g.appendChild e

  ret =
    size:
      width : lw + r2   + lw
      height: lw + r2*2 + lw
          
_view = (svg, styles) ->
  r    = styles.radius || 16
  r2   = r*2
  extw = r*0.4              # 40% of r
  lw   = styles.lineWidth  # lw: line-width

  g = svg_g svg

  g.appendChild ne 'circle', cx:lw + r + extw, cy:lw + r, r:r

  d = [
     ["M", lw, r]
     ["l", extw, 0]
     ["M", lw, 0]
     ["l", 0, r2]
    ]
  e = ce 'path'
  e.setAttribute "d", to_d d
  g.appendChild e

  ret =
    size:
      width :lw + r2 + extw + lw
      height:lw + r2 +        lw

_controller = (svg, styles) ->
  r    = styles.radius || 16
  r2   = r*2
  exth = r*0.4              # 40% of r
  lw   = lh = styles.lineWidth  # lw: line-width
  dy   = 0
  effectext = 0

  g = svg_g svg

  g.appendChild ne 'circle', cx:lw + r, cy:lw + r + exth, r:r
 
  x0 = lw + r*0.8
  x1 = lw + r*1.2
  y0 = lh + exth
  d = [
     ["M", x0, y0]
     ["L", x1, lh + exth/4]
     ["M", x0, y0]
     ["L", x1, lh + exth*7/4]
    ]
  e = ne 'path', d:to_d d
  g.appendChild e

  ret =
    size:
      width :lw + r2 + lw + effectext
      height:lw + r2 + lw + effectext + exth

_entity = (svg, styles) ->
  r    = styles.radius || 16
  r2   = r*2
  exth = r*0.4             # 40% of r
  lw   = styles.lineWidth  # lw: line-width

  g = svg_g svg
  
  g.appendChild ne 'circle', cx:lw + r, cy:lw + r, r:r

  d = [
     ["M", lw + r,  r2]         # v-line (short)
     ["L", lw + r,  r2 + exth]
     ["M", 0,       r2 + exth]  # h-line (long)
     ["L", r2 + lw, r2 + exth]  #
    ]
  e = ne 'path', d:to_d d
  g.appendChild e
  
  ret =
    size:
      width :lw + r2 + lw
      height:lw + r2 + exth + lw

_render = (svg, renderer, args) ->
  #return unless svg.getContext  ## for test on CLI

  styles = $.extend {}, _STYLES, args

  {size, paths} = renderer svg, styles

  dw = (styles.shadowOffsetX || 0) + (styles.shadowBlur/2 || 0)
  dh = (styles.shadowOffsetY || 0) + (styles.shadowBlur/2 || 0)
  $(svg).attr
    width:size.width + dw, height:size.height + dh
    "data-actual-width":size.width, "data-actual-height":size.height

core = require "core.coffe"
HTMLElement = require "HTMLElement.coffee"

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

module.exports = IconElement
