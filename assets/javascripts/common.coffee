##
class JUMLYHTMLElement
  constructor: ->
    cls = JUMLY.Naming.toCSSClass @constructor.name
    p = $.extend this, $("<div>").addClass cls
    a = Array.prototype.slice.apply arguments
    a.unshift p
    @_build_?.apply this, a
    this

JUMLY.HTMLElement = JUMLYHTMLElement

class JUMLYDiagram extends JUMLY.HTMLElement
JUMLYDiagram::_build_ = (div)->
    div.addClass "diagram"
    
JUMLYDiagram::_regByRef_ = (id, obj)->
  ref = JUMLY.Naming.toRef id
  throw new Error("Already exists for '#{ref}' in the " + $.kindof(this)) if this[ref]
  if (a = $("##{ref}")).length > 0
    err = new Error("Element which has same ID(#{ref}) already exists in the document.")
    err.element = a
    throw err
  this[ref] = obj
  ref

JUMLY.Diagram = JUMLYDiagram


uml = jQuery.uml
###
#JUMLYObject
    activate()
    isLeftAt()
    isRightAt()
    iconify(fixture)
    message([incoming | outgoing])
###
class JUMLYObject
    constructor: (props, opts) ->
        jQuery.extend this, JUMLYObject.newNode()
    @newNode = ->
	     $("<div>").addClass("object")
	               .append($("<div>").addClass("name"))

# activate
JUMLYObject::activate = ->
    _as = uml.lang._as
    occurr = uml(type:".occurrence", ".object":this)
    iact = uml(type:".interaction", ".occurrence":_as(".actor":null, ".actee":occurr), ".actor":null, ".actee":occurr)
    iact.addClass "activated"
    iact.find(".message").remove()
    iact.append(occurr)
    @parent().append(iact)
    occurr

# isLeftAt
JUMLYObject::isLeftAt = (a) ->
	@offset().left < a.offset().left

# isRightAt
JUMLYObject::isRightAt = (a) ->
	(a.offset().left + a.width()) < @offset().left

# iconify
JUMLYObject::iconify = (fixture, styles) ->
    unless typeof fixture is "function"
        fixture = $.uml.icon["." + fixture] || $.uml.icon[".actor"]
    canvas = $("<canvas>").addClass("icon")
    container = $("<div>").addClass("icon-container")
    @addClass("iconified")
        .prepend(container.append canvas)

    {size, styles} = fixture canvas[0], styles
    container.css width:size.width, height:size.height
    render = =>
        name = @find(".name")
        styles.fillStyle   = name.css("background-color")
        styles.strokeStyle = name.css("border-top-color")
        fixture canvas[0], styles
    this.renderIcon = -> render()
    this

# Lost message
JUMLYObject::lost = ->
    this.activate()
        .interact(null, {stereotype:".lost"})

uml.def ".object", JUMLYObject
class JUMLYRelationship
    constructor: (props, opts) ->
        @src = opts.source
        @dst = opts.destination
        jQuery.extend this, JUMLYRelationship.newNode()
        this
    @newNode = ->
        $("<div>").addClass("relationship")
                  .append($("<canvas>").addClass("icon"))
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

JUMLYRelationship::render = ->
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

$.uml.def ".relationship", JUMLYRelationship
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

$.uml.icon ?= {}
$.extend $.uml.icon, {
    ".actor"     : _render_actor
    ".view"      : _render_view
    ".controller": _render_controller
    ".entity"    : _render_entity
}

class JUMLYNote
    constructor: (props, opts) ->
        jQuery.extend this, JUMLYNote.newNode()
        @html opts.name
    @newNode = ->
        $("<div>").addClass("note")

JUMLYNote::attach = (target, opts) ->
    self = this
    opts = $.extend {left:0, top:0}, opts

    if opts?.width then @width opts.width
    if opts?["min-height"] then @css "min-height", opts["min-height"]

    target.parents(".diagram")
        .append(this)
        .self().bind "afterCompose", (_, e) ->
            pos = target.offset()
            pos.left += opts.left
            pos.top  += opts.top
            self.offset left:pos.left, top:pos.top
   this 

jQuery.uml.def ".note", JUMLYNote
