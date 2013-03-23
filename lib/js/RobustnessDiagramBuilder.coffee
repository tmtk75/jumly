DiagramBuilder = require "DiagramBuilder"
RobustnessDiagram = require "RobustnessDiagram"

class RobustnessDiagramBuilder extends DiagramBuilder
  constructor: (@diagram) ->

RobustnessDiagramBuilder::build = ->
  new RobustnessDiagram

RobustnessDiagramBuilder::actor = ->

RobustnessDiagramBuilder::view = ->

RobustnessDiagramBuilder::controller= ->

RobustnessDiagramBuilder::entity = ->

core = require "core"
if core.env.is_node
  module.exports = RobustnessDiagramBuilder
else
  core.exports RobustnessDiagramBuilder

