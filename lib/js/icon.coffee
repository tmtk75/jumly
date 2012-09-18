JUMLY = window.JUMLY
_STYLES =
    radius       : 14    # Radius of each circle
    lineWidth    : 1.5
    fillStyle    : 'white'
    strokeStyle  : 'gray'
    shadowBlur   : 4
    shadowColor  : 'rgba(0,0,0,0.33)' # 'transparent black'
    shadowOffsetX: 10
    shadowOffsetY: 5

consts =
	ACTOR_HEAD       : 8
	VIEW_RADIUS      : 14
	CONTROLLER_RADIUS: 14
	ENTITY_RADIUS    : 14

_path = $.g2d.path

_actor_renderer = (ctxt, styles) ->
    r    = styles.radius*0.66 || consts.ACTOR_HEAD
    r2   = r*2
    exth = r*0.25                        # 25% of radius
    lw   = Math.round(styles.lineWidth)  # lw: line-width
    
    # Render a head
    r0 = ->
        ctxt.arc lw + r, lw + r, r, 0, Math.PI*2, true
        ctxt.fill()
        ctxt.shadowColor = 'transparent'
        ctxt.stroke()
    
    # Render a body
    r1 = ->
        dh = 3*lw
        dv = r2*0.85
        new _path(ctxt)
            .moveTo(0, r2 + lw + exth).line(lw + r2 + lw, 0)  # actor's arms (h-line) 
            .moveTo(lw + r, r2 + lw).line(0, r2*0.35)         # actor's body (v-line)
            .line(-r2 + dh, dv).move(r2 - dh, -dv)  # actor's right leg, and back to the groin :)
            .line( r2 - dh - 1, dv - 1)                     # actor's left leg
        ctxt.shadowColor = styles.shadowColor
        ctxt.stroke()
    
    ret =
        size:
            width : lw + r2   + lw
            height: lw + r2*2 + lw
        paths: [r0, r1]
            
_view_renderer = (ctxt, styles) ->
    r    = styles.radius || consts.VIEW_RADIUS
    r2   = r*2
    extw = r*0.4              # 40% of r
    lw   = styles.lineWidth  # lw: line-width

    r0 = ->
        ctxt.arc lw + r + extw, lw + r, r, 0, Math.PI*2, true
        ctxt.fill()
        ctxt.shadowColor = 'transparent'
        ctxt.stroke()
   
    r1 = ->
        new _path(ctxt)
            .moveTo(lw, r)
            .line(extw, 0)
            .moveTo(lw, 0)
            .line(0, r2)
        #ctxt.shadowColor = styles.shadowColor
        ctxt.stroke()

    ret =
        size:
            width :lw + r2 + extw + lw
            height:lw + r2 +        lw
        paths: [r0, r1]

_controller_renderer = (ctxt, styles) ->
    r    = styles.radius || consts.CONTROLLER_RADIUS
    r2   = r*2
    exth = r*0.4              # 40% of r
    lw   = lh = styles.lineWidth  # lw: line-width
    dy   = 0
    effectext = 0

    r0 = ->
        ctxt.arc lw + r, lw + r + exth, r, 0, Math.PI*2, true
        ctxt.fill()
        ctxt.shadowColor = 'transparent'
        ctxt.stroke()
   
    r1 = ->
        new _path(ctxt)
            .moveTo(lw + r,     lh + exth)
        	.lineTo(lw + r*1.4, lh + exth/4)
            .moveTo(lw + r,     lh + exth)
            .lineTo(lw + r*1.4, lh + exth*7/4)
        ctxt.stroke()

    ret =
        size:
            width :lw + r2 + lw + effectext
            height:lw + r2 + lw + effectext + exth
        paths: [r0, r1]

_entity_renderer = (ctxt, styles) ->
    r    = styles.radius || consts.ENTITY_RADIUS
    r2   = r*2
    exth = r*0.4             # 40% of r
    lw   = styles.lineWidth  # lw: line-width

    r0 = ->
        ctxt.arc lw + r, lw + r, r, 0, Math.PI*2, true
        ctxt.fill()
        ctxt.shadowColor = 'transparent'
        ctxt.stroke()
    
    r1 = ->
        ctxt.shadowColor = styles.shadowColor
        new _path(ctxt)
            .moveTo(lw + r,  r2)         # v-line (short)
            .lineTo(lw + r,  r2 + exth)  # 
            .moveTo(0,       r2 + exth)  # h-line (long)
            .lineTo(r2 + lw, r2 + exth)  # 
        ctxt.stroke()
    
    ret =
        size:
            width :lw + r2 + lw
            height:lw + r2 + exth + lw
        paths: [r0, r1]

_size_canvas = (canvas, size, styles) ->
    dw = styles.shadowOffsetX + styles.shadowBlur || 0
    dh = styles.shadowOffsetY + styles.shadowBlur || 0
    $(canvas).attr width:size.width + dw, height:size.height + dh
    size

_render_icon = (canvas, renderer, args) ->
    args = args || {}
    styles = $.extend _STYLES, args

    ctxt = canvas.getContext '2d'
    {size, paths} = renderer ctxt, styles
    _size_canvas canvas, size, styles

    $.extend ctxt, styles
    for e in paths
        ctxt.beginPath()
        e()

    r =
        size: size
        styles: styles

_render_actor = (canvas, styles) -> _render_icon canvas, _actor_renderer, styles

_render_view = (canvas, styles) -> _render_icon canvas, _view_renderer, styles

_render_controller = (canvas, styles) -> _render_icon canvas, _controller_renderer, styles

_render_entity = (canvas, args) -> _render_icon canvas, _entity_renderer, args

$.jumly.icon ?= {}
$.extend $.jumly.icon, {
    ".actor"     : _render_actor
    ".view"      : _render_view
    ".controller": _render_controller
    ".entity"    : _render_entity
}
