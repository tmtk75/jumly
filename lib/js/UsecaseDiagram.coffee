
class UMLUsecase
  constructor: (props, opts) ->
    jQuery.extend this, UMLUsecase.newNode()
    this
  @newNode = ->
    $("<div>").addClass("usecase")
              .append($("<div>").addClass("icon")
                                .append($("<div>").addClass("name")))

UMLUsecase::pack = (T = (1 + 2.2360679)/2) ->
    icon = @find(".icon")
    name = @find(".icon .name")
    minwidth  = icon.css("min-width").toInt()
    minheight = icon.css("min-height").toInt()
    R = minwidth/minheight
    
    h = icon.height()
    v = name.height()

    t = h/v
    t = T if t > T
    icon.css width:minwidth*t, height:minheight*t

class UMLActor
    constructor: (props, opts) ->
        jQuery.extend this, $.jumly ".object"
        @iconify ".actor"
        @addClass "actor"
        this

class UMLSystemBoundary
    constructor: (props, opts) ->
        jQuery.extend this, UMLSystemBoundary.newNode()
        this
    @newNode = ->
        $("<div>").addClass("system-boundary")
                  .append $("<div>").addClass "name"

class JUMLYUsecaseDiagram extends require("Diagram")

set_min_size = (nodes) ->
    nodes.each (i, e) ->
        e = $(e)
        if w = e.css "min-width"  then e.width(w) .css width :w
        if h = e.css "min-height" then e.height(h).css height:h

shift_usecase_down_to_above = (nodes) ->
    nodes.each (i, e) ->
        $(e).find("> .usecase .icon").each (i, e) ->
            e = $(e)
            if i > 0
                e.css "margin-top", -e.css("min-height").toInt()/3

bind_between = (nodes, diag) ->
  nodes.each (i, e) ->
    src = $(e).self()
    find_with_id = (id) ->
      return diag[id] if diag[id]
      return id unless (typeof id is "string") or (typeof id is "number") ## Regard as the own object
      if (t = $("#" + id, diag)).length > 0
        t
    bind = (type) ->
      $(src.jprops()[type]).each (i, e) ->
        return unless dst = find_with_id e
        link = $.jumly ".relationship", src:src, dst:dst
        link.addClass type
        diag.append link
    bind "use"
    bind "extend"
    bind "include"

JUMLYUsecaseDiagram::align_actors_ = ->
    tb = @find(".system-boundary").mostTopBottom()
    height = tb.height()
    actors = @find(".actor")
    dh = height / actors.length
    actors.each (i, e) ->
        dy = if i > 1 then (if i % 2 is 0 then dh else -dh) else 0
        y = tb.top + dy + height/2
        $(e).offset top:y

JUMLYUsecaseDiagram::render = ->
    @find(".relationship").each (i, e) ->
        $(e).self().render()

JUMLYUsecaseDiagram::compose = ->
    set_min_size @find(".usecase .icon")
    shift_usecase_down_to_above @find(".system-boundary")
    bind_between @find(".usecase, .actor"), this
    @align_actors_()
    @render()
    #@width @mostLeftRight().width()
    @height @mostTopBottom().height()
    this

#JUMLY.def ".usecase-diagram", JUMLYUsecaseDiagram



class JUMLYUsecaseDiagramBuilder extends require("DiagramBuilder")
  constructor: (@_diagram, @_boundary) ->

JUMLYUsecaseDiagramBuilder::new_ = (type, uname) ->
    uname = $.jumly.normalize uname
    a = $.jumly type, uname
    $.extend a.jprops(), uname
    a

JUMLYUsecaseDiagramBuilder::_declare_ = (uname, type, target)->
  a = @new_ type, uname
  target.append a
  b = JUMLY.Identity.normalize uname

  ref = @_diagram._regByRef_ b.id, a
  eval "#{ref} = a"

JUMLYUsecaseDiagramBuilder::usecase = (uname) ->
  @_declare_ uname, ".usecase", @_boundary

JUMLYUsecaseDiagramBuilder::actor = (uname) ->
  @_declare_ uname, ".actor", @_diagram

JUMLYUsecaseDiagramBuilder::boundary = (name, acts) ->
  @_diagram = @diagram unless @_diagram  ##WORKAROUND: to v0.1.0
  name ?= ""
  return curry_ this, @boundary, id if id = $.jumly.identify name
  boundary = @new_ ".system-boundary", name

  ctxt = new JUMLYUsecaseDiagramBuilder(@_diagram, boundary)
  ctxt.diagram = @_diagram  ##WORKAROUND: to v0.1.0
  acts.apply ctxt 
  if @_boundary
    @_boundary.append boundary
  else
    @_diagram.append boundary
  norm = JUMLY.Identity.normalize name
  @_diagram._regByRef_ norm.id
  this

JUMLYUsecaseDiagramBuilder::compose = (something) ->
    if typeof something is "function"
        something @_diagram
    else if typeof something is "object" and something.each
        something.append @_diagram
    else
        throw something + " MUST be a function or a jQuery object"
    @_diagram.compose()
    this

JUMLYUsecaseDiagram::boundary = (name, acts)->
  ctxt = new JUMLYUsecaseDiagramBuilder(this)
  ctxt.boundary name, acts
  ctxt

#JUMLY.DSL type:".usecase-diagram", compileScript: (script) ->
#    diag = $.jumly ".usecase-diagram"
#    sbname = $(script).attr "system-boundary-name"
#    diag.boundary sbname, ->
#        unless sbname
#            @_boundary.addClass("out-of-bounds").removeClass("system-boundary")
#                      .find(".name").remove()
#        eval CoffeeScript.compile script.html()
#    diag


#UsecaseDiagramBuilder = JUMLYUsecaseDiagramBuilder
