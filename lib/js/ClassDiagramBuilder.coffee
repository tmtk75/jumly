DiagramBuilder = require "DiagramBuilder"

class ClassDiagramBuilder extends DiagramBuilder
  constructor: (@diagram) ->

ClassDiagramBuilder::def = (props)->
  @diagram.declare Identity.normalize props

##Deprecated
ClassDiagramBuilder::start = (acts)-> acts.apply this, []

DSL = ->
DSL type:".class-diagram", compileScript: (script) ->
  b = new ClassDiagramBuilder
  b.build script.html()


module.exports = ClassDiagramBuilder
