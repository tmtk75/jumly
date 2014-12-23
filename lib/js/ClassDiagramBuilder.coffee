DiagramBuilder = require "DiagramBuilder.coffee"
core = require "core.coffee"

class ClassDiagramBuilder extends DiagramBuilder
  constructor: (@diagram) ->

ClassDiagramBuilder::def = (props)->
  @diagram.declare core_.normalize props

##Deprecated
ClassDiagramBuilder::start = (acts)-> acts.apply this, []

DSL = ->
DSL type:".class-diagram", compileScript: (script) ->
  b = new ClassDiagramBuilder
  b.build script.html()


module.exports = ClassDiagramBuilder
