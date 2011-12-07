class UMLComponent
    constructor: (props, opts) ->
        jQuery.extend this, UMLComponent.newNode()
        this
    @newNode = ->
        $("<div>").addClass("component")
                  .append($("<div>").addClass("frame")
                                    .append($("<div>").addClass("icon"))
                                    .append($("<div>").addClass("stereotype").text("<<component>>"))
                                    .append($("<div>").addClass("name")))

$.uml.def ".component", UMLComponent


class UMLPort
    constructor: (props, opts) ->
        jQuery.extend this, UMLPort.newNode()
        this
    @newNode = ->
        $("<div>").addClass("port")
                  .append($("<div>").addClass("name"))
                  .append $("<div>").addClass("icon")

$.uml.def ".port", UMLPort


class UMLProvidedInterface
    constructor: (props, opts) ->
        jQuery.extend this, UMLProvidedInterface.newNode()
        this
    @newNode = ->
        $("<div>").addClass("provided-interface")
                  .append($("<div>").addClass("name"))
                  .append $("<div>").addClass("icon")

$.uml.def ".provided-interface", UMLProvidedInterface


class UMLRequiredInterface
    constructor: (props, opts) ->
        jQuery.extend this, UMLRequiredInterface.newNode()
        this
    @newNode = ->
        $("<div>").addClass("required-interface")
                  .append($("<div>").addClass("name"))
                  .append $("<div>").addClass("icon")

$.uml.def ".required-interface", UMLRequiredInterface

class UMLComponentDiagram
    constructor: (props, opts) ->
        jQuery.extend this, UMLComponentDiagram.newNode()
        this
    @newNode = ->
        $("<div>").addClass("diagram")
                  .addClass("component-diagram")

UMLComponentDiagram::compose = ->
    @trigger "beforeCompose", [this]
    @compose_.apply arguments
    @trigger "afterCompose", [this]
    this

UMLComponentDiagram::compose_ = ->
    @find(".component").each (i, e) ->
        compo = $(e).self()
        compo.find(".provided-interface, .required-interface").each (i, e) ->
            frame = compo.find(".frame")
            to_left = (e) ->
                if i is 0
                    t = frame.offset().top
                else
                    t = e.prev(1).outerBottom()
                e.offset top:t
                e.addClass "to-left"
            to_right = (e) ->
                x = frame.offset().left + frame.outerWidth()
                e.offset left:x
                e.find(".icon").css("-webkit-transform", "scale(-1, 1)")
                t = e.prev().offset().top
                e.offset top:t
                e.addClass "to-right"
            if i % 2 is 0
                to_left $(e)
            else
                to_right $(e)
    
    @find(".relationship").each (i, e) ->
        $(e).self().render()

$.uml.def ".component-diagram", UMLComponentDiagram
