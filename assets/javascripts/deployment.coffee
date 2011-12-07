class UMLArtifact
    constructor: (props, opts) ->
        jQuery.extend this, UMLArtifact.newNode()
        @_movingTo = []
        this
    @newNode = ->
        $("<div>").addClass("artifact")
                  .append($("<div class='frame'/>")
                      .append($("<div class='stereotype'/>").text "<<artifact>>")
                      .append("<div class='name'/>")
                      .append("<div class='edge-top'/>")
                      .append("<div class='edge-right'/>"))

UMLArtifact::preferredWidth = (w) ->
    

UMLArtifact::moveTo = (x, y) ->
    self = this
    @_movingTo.push -> self._moveTo x, y

UMLArtifact::_moveTo = (x, y) ->
    q = {}
    if typeof x is "object"
        q = x
    else if typeof x is "number" and typeof y is "number"
        q = {left:x, top:y}
    p = @parents(".diagram:eq(0)").offset()
    if q.left?
        @css "margin-left":q.left + "px"
    
    index = @index()
    margintotal = 0
    #console.log "----------"
    @parents(".diagram:eq(0)").find(".artifact").each (i, e) ->
        if i >= index then return
        mt = $(e).css("margin-top")?.toInt()
        mt ?= 0
        margintotal += mt + $(e).outerHeight()
        #console.log "i=", i, "margin-total=", margintotal, "mt=", mt
    my = 0
    if q.top?
        my = q.top - margintotal
    else
        my = -margintotal
    #console.log "last", "my=", my, "margin-total", margintotal, "q.top=", q.top, "offset.top"
    @css "margin-top":my + "px"

    
UMLArtifact::render = ->
    $(@_movingTo).each (i, e) ->
        e()

    f = @find("> .frame")
    t = f.find("> .edge-top")
    r = f.find("> .edge-right")
    bw = f.css("border-right-width").toInt()

    r.css("position":"absolute")
     .height f.height()

    h = Math.round r.outerWidth()/Math.sqrt(3)

    t.offset left:f.offset().left + bw/2, top:f.offset().top - t.outerHeight()
    r.offset left:f.outerRight(), top:f.offset().top - h/2

$.uml.def ".artifact", UMLArtifact


class UMLDeploymentDiagram
    constructor: (props, opts) ->
        jQuery.extend this, UMLDeploymentDiagram.newNode()
        this
    @newNode = ->
        $("<div>").addClass("diagram")
                  .addClass("deployment-diagram")

UMLDeploymentDiagram::compose = ->
    @trigger "beforeCompose", [this]
    $(".artifact").each (i, e) ->
        $(e).self().render()
    @trigger "afterCompose", [this]
    this

$.uml.def ".deployment-diagram", UMLDeploymentDiagram

