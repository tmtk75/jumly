HTMLElement = require "HTMLElement"
class Relationship extends HTMLElement

Relationship::_build_ = (div, opts)->
  @src = opts.src
  @dst = opts.dst
  div.append($("<canvas>").addClass("icon"))
     .append($("<div>").addClass("name"))

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

$.fn.cssAsInt = (name) -> a = @css(name); if a then parseInt a else 0

Relationship::render = ->
    margin_left = $("body").cssAsInt "margin-left"
    margin_top  = $("body").cssAsInt "margin-top"
    pt = (obj) ->
        s = obj.offset()
        dh = 0*(obj.cssAsInt "margin-left")  - margin_left
        dv = 0*obj.css("margin-top").toInt() - margin_top
        p = left:s.left + obj.outerWidth()/2 + dh, top:s.top + obj.outerHeight()/2 + dv
   
    rect = (p, q) ->
        a = left:Math.min(p.left, q.left), top:Math.min(p.top, q.top)
        b = left:Math.max(p.left, q.left), top:Math.max(p.top, q.top)
        w = b.left - a.left + 1
        h = b.top  - a.top  + 1
        hs = Math.sign(q.left - p.left)
        vs = Math.sign(q.top  - p.top)
        l = Math.sqrt w*w + h*h
        r = left:a.left, top:a.top, width:w, height:h, hsign:hs, vsign:vs, hunit:hs*w/l, vunit:vs*h/l

    expand = (rect, val) ->
        if typeof val is "number" then return expand rect, left:val, top:val, right:val, bottom:val
        r = $.extend {}, rect
        for d of val
            switch d
                when "left"
                    r.left  -= val[d]
                    r.width += val[d]
                when "top"
                    r.top    -= val[d]
                    r.height += val[d]
                when "right"
                    r.width += val[d]
                when "bottom"
                    r.height += val[d]
        r

    srcicon = @src.find(".icon")
    dsticon = @dst.find(".icon")
    p = pt srcicon
    q = pt dsticon
    r = rect p, q

    cr = 2
    aa = r.hunit*dsticon.outerWidth()/cr
    bb = r.vunit*dsticon.outerHeight()/cr
    cc = r.hunit*srcicon.outerWidth()/cr
    dd = r.vunit*srcicon.outerHeight()/cr
    s = x:p.left - r.left + cc, y:p.top  - r.top + dd
    t = x:q.left - r.left - aa, y:q.top  - r.top - bb

    margin = 4
    r = expand r, margin
    @width r.width
    @height r.height
    @offset left:r.left, top:r.top

    ctxt = @find("canvas").css( width:r.width, height:r.height)
                          .attr(width:r.width, height:r.height)[0]
                          .getContext "2d"
    ctxt.save()
    ctxt.translate margin, margin
    style = $.extend {}, MESSAGE_STYLE, pattern:[4, 4], shape:'line'
    if @hasClass("extend")
        style = $.extend style, shape:'dashed'
    #if @hasClass("use")
    #    style = $.extend style, width:0, base:0, height:0
    $.g2d.arrow ctxt, s, t, style
    ctxt.restore()


core = require "core"
if core.env.is_node
  module.exports = Relationship
else
  core.exports Relationship

