###
This is capable to render followings:
- Synmetric figure
- Poly-line
###
class Shape
    constructor: (@ctxt)->
        @pos = left:0, top:0
        @memento = []

Shape::backtrack = (depth)->
    @ctxt.save()
    @ctxt.scale 1, -1
    i = 0
    while m = @memento.pop()
        m()
        i += 1
        if i >= depth
            break
    @ctxt.restore()
    this

Shape::line = (dx, dy, b)->
    @pos.left += dx
    @pos.top  += dy
    @ctxt.lineTo @pos.left, @pos.top
    _pos = left:@pos.left, top:@pos.top
    @memento.push (rx, ry) => @ctxt.lineTo _pos.left - dx, _pos.top - dy
    this

Shape::move = (dx, dy)->
    @pos.left += dx
    @pos.top  += dy
    @ctxt.moveTo @pos.left, @pos.top
    _pos = left:@pos.left, top:@pos.top
    @memento.push (rx, ry) => @ctxt.moveTo _pos.left - dx, _pos.top - dy
    this

Shape::lineTo = (p, q)->
    _pos = left:@pos.left, top:@pos.top
    @ctxt.lineTo p, q
    @pos.left = p
    @pos.top  = q
    @memento.push => @ctxt.lineTo _pos.left, _pos.top
    this

Shape::moveTo = (p, q)->
    _pos = left:@pos.left, top:@pos.top
    @ctxt.moveTo p, q
    @pos.left = p
    @pos.top  = q
    @memento.push => @ctxt.moveTo _pos.left, _pos.top
    this

###
 * Convert to polar coordinate system from Cartesian coordinate system.
 * @return {
 *   gradients  :
 *   radius     :
 *   quadrants  : {x, y} x:1 or -1, y:1 or -1
 *   declination:
 *   offset     :
 * }
###
to_polar_from_cartesian = (src, dst)->
    dx = dst.left - src.left
    dy = dst.top  - src.top
    offset:
        left: src.left
        top : src.top
    radius     : Math.sqrt dx*dx + dy*dy
    declination: Math.atan dy/dx
    quadrants  :
        x: if dx != 0 then dx/Math.abs(dx) else 1
        y: if dy != 0 then dy/Math.abs(dy) else 1

_line_to = (ctxt, src, dst, styles)->
    unless styles
        ctxt.moveTo src.left, src.top
        ctxt.lineTo dst.left, dst.top
        return

    styles = $.extend pattern:[4, 4], styles
    
    p = to_polar_from_cartesian src, dst
    ctxt.save()
    ctxt.translate p.offset.left, p.offset.top
    ctxt.rotate p.declination
    ctxt.scale p.quadrants.x, p.quadrants.y

    ctxt.moveTo 0, 0
    pattern = styles.pattern
    plen = pattern[0] + pattern[1]
    if p.radius > 0
        for i in [0..p.radius-1] by plen
            x = i + pattern[0]
            x = p.radius - 1 if p.radius - 1 <= x
            ctxt.lineTo x, 0
            ctxt.moveTo i + plen, 0
    ctxt.restore()

_render_both = (ctxt, a, r, e, dt)->
    a.line(e.height, (e.width + dt))
     .line(0, -dt)
     .line(r - e.height*2, 0)
     .line(0, dt)
     .line(e.height, -(e.width + dt))
     .backtrack()
    ctxt.closePath()
_render_line = (ctxt, a, r, e, dt)->
    a.moveTo(0, 0)
     .line(r, 0)
     .line(-e.height, e.base)
     .move(e.height, -e.base)
     .line(-e.height, -e.base)
    delete e.fillStyle
_render_line2 = (ctxt, a, r, e, dt)->
    a.moveTo(0, 0)
     .line(r - e.height, 0)
     .line(0,         e.base)
     .line(e.height, -e.base)
     .backtrack()
_render_dashed = (ctxt, a, r, e, dt)->
    _line_to ctxt, {left:0, top:0}, {left:r, top:0}, {pattern:e.pattern}
    _line_to ctxt, {left:r, top:0}, {left:r - e.height, top: e.base}
    _line_to ctxt, {left:r, top:0}, {left:r - e.height, top:-e.base}
    delete e.fillStyle
_render_dashed2 = (ctxt, a, r, e, dt)->
    _line_to ctxt, {left:0, top:0}, {left:r - e.height, top:0}, {pattern:e.pattern}
    a.moveTo(r - e.height, 0)
     .line(        0,  e.base)
     .line( e.height, -e.base)
     .line(-e.height, -e.base)
     .line(        0,  e.base)
_render_normal = (ctxt, a, r, e, dt)->
    a.moveTo(0, 0)
     .line(0, e.width)
     .line(r - e.height, 0)
     .line(0, dt)
     .line(e.height, -(e.width + dt))
     .backtrack()
    ctxt.closePath()

###
 * Draw an allow shape on a canvas.
 * This allow shape is defined by following style's 3 parameters.
 * @param styles: {
 *   width : Width of the edge for rectangle,
 *   base  : Length of the base edge,
 *   height: Height of triangle,
 * }
 * @param ctxt
 * @param src, dst
###
shape_arrow = (ctxt, src, dst, styles)->
    p = to_polar_from_cartesian {left:src.x, top:src.y}, {left:dst.x, top:dst.y}
    r = p.radius
    ctxt.save()
    ctxt.translate src.x, src.y
    ctxt.rotate p.declination
    ctxt.scale p.quadrants.x, p.quadrants.y
    
    e = $.extend width: 20, base: 35, height: 50, pattern:[4, 4], shape:null, styles
    e.lineWidth ?= 1.0
    $.extend ctxt, e
    ctxt.beginPath()

    if e.tosrc
        ctxt.translate r, 0
        ctxt.rotate Math.PI
    
    a = new Shape ctxt
    dt = e.base - e.width
    switch styles.shape
        when 'both'    then _render_both    ctxt, a, r, e, dt
        when 'line'    then _render_line    ctxt, a, r, e, dt
        when 'dashed'  then _render_dashed  ctxt, a, r, e, dt
        when 'dashed2' then _render_dashed2 ctxt, a, r, e, dt
        when 'line2'   then _render_line2   ctxt, a, r, e, dt
        else                _render_normal  ctxt, a, r, e, dt
    ctxt.stroke()
    if e.fillStyle
        ctxt.fill()
    ctxt.restore()

self = require: unless typeof require is "undefined" then require else JUMLY.require

g2d =
  arrow: shape_arrow
  path : Shape

core = self.require "core"
if core.env.is_node
  module.exports = g2d
else
  core.exports g2d, "jquery.g2d"
