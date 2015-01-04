HTMLElement = require "HTMLElement.coffee"
g2d = require "jquery.g2d.coffee"

class Relationship extends HTMLElement
  constructor: (args, opts)->
    @src = opts.src
    @dst = opts.dst
    super args, (me)->
      me.addClass("relationship")
        .append(svg = $("<svg width='0' height='0'>").addClass("icon"))
        .append($("<div>").addClass("name"))

      svg[0].appendChild g2d.svg.create "line"
      me

MESSAGE_STYLE =
    width      : 1
    base       : 6
    height     : 10
    lineWidth  : 1.5
    shape      : "dashed"
    pattern    : [8, 8]
    strokeStyle: 'gray'
    fillStyle  : 'gray'
    lineJoin   : 'round'

Math.sign = (x) ->
    if x is 0
        return 0
    else if x > 0
        return 1
    return -1

cssAsInt = (node, name) -> a = node.css(name); if a then parseInt a else 0

Relationship::_point = (obj)->
  margin_left = cssAsInt $("body"), "margin-left"
  margin_top  = cssAsInt $("body"), "margin-top"
  s = obj.offset()
  dh = -(cssAsInt obj, "margin-left") - margin_left
  dv = -(cssAsInt obj, "margin-top") - margin_top
  left:s.left + obj.outerWidth()/2 + dh
  top:s.top + obj.outerHeight()/2 + dv
   
Relationship::_rect = (p, q)->
  a = left:Math.min(p.left, q.left), top:Math.min(p.top, q.top)
  b = left:Math.max(p.left, q.left), top:Math.max(p.top, q.top)
  w = b.left - a.left + 1
  h = b.top  - a.top  + 1
  hs = Math.sign(q.left - p.left)
  vs = Math.sign(q.top  - p.top)
  l = Math.sqrt w*w + h*h
  left:a.left, top:a.top, width:w, height:h, hsign:hs, vsign:vs, hunit:hs*w/l, vunit:vs*h/l

Relationship::render = ->
  p = @_point @src
  q = @_point @dst
  r = @_rect p, q

  cr = 2
  aa = r.hunit*@dst.outerWidth()/cr
  bb = r.vunit*@dst.outerHeight()/cr
  cc = r.hunit*@src.outerWidth()/cr
  dd = r.vunit*@src.outerHeight()/cr
  s = x:p.left - r.left + cc, y:p.top  - r.top + dd
  t = x:q.left - r.left - aa, y:q.top  - r.top - bb

  @width r.width
  @height r.height
  @offset left:r.left, top:r.top

  @find("svg").attr(width:r.width, height:r.height)
              .find("line")
              .attr x1:s.x, y1:s.y, x2:t.x, y2:t.y

module.exports = Relationship
