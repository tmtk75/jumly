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

SVG_NS = "http://www.w3.org/2000/svg"

g2d =
  svg:
    create: (tagname)->
      if typeof document is "undefined"
        $("<#{tagname}>")[0]
      else
        document.createElementNS SVG_NS, tagname
    attrs: (n, attrs)->
       for p of attrs
         n.setAttribute p, attrs[p]
       n
    new: (tagname, attrs)->
      e = @create tagname
      @attrs e, attrs

module.exports = g2d
