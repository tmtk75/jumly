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
self = require: if (typeof module != 'undefined' and typeof module.exports != 'undefined') then require else JUMLY.require

g2d = {}

core = self.require "core"
if core.env.is_node
  module.exports = g2d
else
  core.exports g2d, "jquery.g2d"
