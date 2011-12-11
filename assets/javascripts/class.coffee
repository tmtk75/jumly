###
copyright(c) all rights reserved by Tomotaka Sakuma.
JUMLY by Tomotaka Sakuma is licensed under a Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
###
class UMLClassDiagram
    constructor: (props, opts) ->
        jQuery.extend this, UMLClassDiagram.newNode()
        this
    @newNode = ->
        $("<div>").addClass("diagram")
                  .addClass("class-diagram")

UMLClassDiagram::appear = (norm) ->
    clz = $.jumly ".class", norm
    if norm.stereotype
        clz.find(".stereotype").html norm.stereotype
    else
        clz.find(".stereotype").hide()
    
    $(norm.attrs).each (i, e) -> clz.find(".attrs").append $("<li>").html e
    $(norm.methods).each (i, e) -> clz.find(".methods").append $("<li>").html e
    @append clz

UMLClassDiagram::preferredWidth = ->
    @find(".class .icon").mostLeftRight().width() + 16 ## 16 is WORKAROUND

UMLClassDiagram::preferredHeight = ->
    @find(".class .icon").mostTopBottom().height()

UMLClassDiagram::compose = ->
    @trigger "beforeCompose", [this]
    ## Resize for looks
    @find(".class .icon").each (i, e) ->
        e = $ e
        return null if e.width() > e.height()
        e.width e.height() * (1 + Math.sqrt 2)/2
    @trigger "afterCompose", [this]

    @width @preferredWidth()
    @height @preferredHeight()

    this

###
    <div class="class icon">
        <span class="stereotype">abstract</span>
        <span class="name">UMLObject</span>
        <ul class="attrs">
            <li>name</li>
            <li>stereotypes</li>
        </ul>
        <ul class="methods">
            <li>activate</li>
            <li>isLeftAt(a)</li>
            <li>isRightAt(a)</li>
            <li>iconify(fixture, styles)</li>
            <li>lost</li>
        </ul>
    </div>
###
class UMLClass
    constructor: (props, opts) ->
        jQuery.extend this, UMLClass.newNode()
        this
    @newNode = ->
        icon = $("<div>").addClass("icon")
                         .append($("<div>").addClass("stereotype"))
                         .append($("<div>").addClass("name"))
                         .append(attrs = $("<ul>").addClass("attrs"))
                         .append(methods = $("<ul>").addClass("methods"))
        $("<div>").addClass("object")
                  .addClass("class")
                  .append(icon)

$.jumly.def ".class-diagram", UMLClassDiagram
$.jumly.def ".class", UMLClass
    

class ClassDiagramBuilder extends JUMLY.DSLEvents_
  constructor: (@diagram) ->

ClassDiagramBuilder::def = (props)-> @diagram.appear $.jumly.normalize props

ClassDiagramBuilder::class = ClassDiagramBuilder::def

ClassDiagramBuilder::build = (acts)->
  acts.apply this, []

$.jumly.DSL type:".class-diagram", compileScript: (script) ->
  diag = $.jumly ".class-diagram"
  ctxt = new ClassDiagramBuilder(diag)
  ctxt.start ->
    eval CoffeeScript.compile script.html()
  diag
