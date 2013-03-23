DiagramBuilder = require "DiagramBuilder"
RobustnessDiagram = require "RobustnessDiagram"
IconElement = require "IconElement"

class RobustnessDiagramBuilder extends DiagramBuilder
  constructor: (@_diagram)->
    super()
    @_diagram ?= new RobustnessDiagram

RobustnessDiagramBuilder::build = (src)->
  if src.data
    src.find("*[data-kind]").each (e)=>
      e = $(e)
      @_diagram.append new IconElement(e.text(), kind:$(e).data("kind"))
  else
    super src
  @_diagram

core = require "core"

RobustnessDiagramBuilder::actor = (opt)->
  if typeof opt is "string"
    icon = new IconElement(opt, kind:"actor")
    @_diagram.append icon
  else



RobustnessDiagramBuilder::view = ->

RobustnessDiagramBuilder::controller= ->

RobustnessDiagramBuilder::entity = ->

core = require "core"
if core.env.is_node
  module.exports = RobustnessDiagramBuilder
else
  core.exports RobustnessDiagramBuilder

