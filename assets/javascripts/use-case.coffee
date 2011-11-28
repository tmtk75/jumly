class UMLUsecase
    constructor: (props, opts) ->
        jQuery.extend this, UMLUsecase.newNode()
        this
    @newNode = ->
        $("<div>").addClass("use-case")
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

$.uml.def ".use-case", UMLUsecase

class UMLActor
    constructor: (props, opts) ->
        jQuery.extend this, $.uml ".object"
        @iconify ".actor"
        @addClass "actor"
        this

$.uml.def ".actor", UMLActor


class UMLSystemBoundary
    constructor: (props, opts) ->
        jQuery.extend this, UMLSystemBoundary.newNode()
        this
    @newNode = ->
        $("<div>").addClass("system-boundary")
                  .append $("<div>").addClass "name"

$.uml.def ".system-boundary", UMLSystemBoundary


class UMLUsecaseDiagram
    constructor: (props, opts) ->
        jQuery.extend this, UMLUsecaseDiagram.newNode()
        this
    @newNode = ->
        $("<div>").addClass("diagram")
                  .addClass("use-case-diagram")

set_min_size = (nodes) ->
    nodes.each (i, e) ->
        e = $(e)
        if w = e.css "min-width"  then e.width(w) .css width :w
        if h = e.css "min-height" then e.height(h).css height:h

shift_usecase_down_to_above = (nodes) ->
    nodes.each (i, e) ->
        $(e).find("> .use-case .icon").each (i, e) ->
            e = $(e)
            if i > 0
                e.css "margin-top", -e.css("min-height").toInt()/3

bind_between = (nodes, diag) ->
    nodes.each (i, e) ->
        src = $(e).data("uml:this")

        find_with_id = (id) ->
            return diag[id] if diag[id]
            if (t = $("#" + id, diag)).length > 0
                t

        bind = (type) ->
            $(src.data("uml:property")[type]).each (i, e) ->
                return unless dst = find_with_id e
                link = $.uml ".relationship", source:src, destination:dst
                link.addClass type
                diag.append link
        
        bind "use"
        bind "extend"
        bind "include"

UMLUsecaseDiagram::align_actors_ = ->
    tb = @find(".system-boundary").mostTopBottom()
    height = tb.height()
    actors = @find(".actor")
    dh = height / actors.length
    actors.each (i, e) ->
        dy = if i > 1 then (if i % 2 is 0 then dh else -dh) else 0
        y = tb.top + dy + height/2
        $(e).offset top:y

UMLUsecaseDiagram::render = ->
    @find(".relationship").each (i, e) ->
        $(e).data("uml:this").render()

UMLUsecaseDiagram::compose = ->
    @trigger "beforeCompose", [this]
    set_min_size @find(".use-case .icon")
    shift_usecase_down_to_above @find(".system-boundary")
    bind_between @find(".use-case, .actor"), this
    @align_actors_()
    @render()
    #@width @mostLeftRight().width()
    @height @mostTopBottom().height()
    @trigger "afterCompose", [this]
    this
    
$.uml.def ".use-case-diagram", UMLUsecaseDiagram
