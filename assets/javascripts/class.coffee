##
class JUMLYClassDiagram extends JUMLY.Diagram
JUMLYClassDiagram::build = ->
  $("<div>").addClass("diagram")
            .addClass("class-diagram")

JUMLYClassDiagram::member = (kind, clz, normval)->
  $(normval["#{kind}s"]).each (i, e)->
    clz.find(".#{kind}s").append $("<li>").addClass(e)
      .attr("id", "#{normval.id}-#{kind}-#{e}").html e

JUMLYClassDiagram::declare = (normval) ->
  clz = $.jumly ".class", normval
  if normval.stereotype
    clz.find(".stereotype").html normval.stereotype
  else
    clz.find(".stereotype").hide()
    
  @member(kind, clz, normval) for kind in ["attr", "method"]

  ref = @_regByRef_ normval.id, clz
  eval "#{ref} = clz"
  @append clz

JUMLYClassDiagram::preferredWidth = ->
  @find(".class .icon").mostLeftRight().width() + 16 ##WORKAROUND: 16 is magic number.

JUMLYClassDiagram::preferredHeight = ->
  @find(".class .icon").mostTopBottom().height()

JUMLYClassDiagram::compose = ->
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
class JUMLYClass extends JUMLY.HTMLElement
JUMLYClass::build = ->
  icon = $("<div>")
           .addClass("icon")
           .append($("<div>").addClass "stereotype")
           .append($("<div>").addClass "name")
           .append($("<ul>").addClass "attrs")
           .append($("<ul>").addClass "methods")
  $("<div>").addClass("object")
            .addClass("class")
            .append(icon)

JUMLY.define ".class-diagram", JUMLYClassDiagram
JUMLY.define ".class", JUMLYClass


class JUMLYClassDiagramBuilder extends JUMLY.DiagramBuilder
  constructor: (@diagram) ->

JUMLYClassDiagramBuilder::def = (props)->
  @diagram.declare JUMLY.Identity.normalize props

##Deprecated
JUMLYClassDiagramBuilder::start = (acts)-> acts.apply this, []

$.jumly.DSL type:".class-diagram", compileScript: (script) ->
  diag = $.jumly ".class-diagram"
  ctxt = new JUMLYClassDiagramBuilder(diag)
  ctxt.start ->
    eval CoffeeScript.compile script.html()
  diag

JUMLY.ClassDiagramBuilder = JUMLYClassDiagramBuilder
