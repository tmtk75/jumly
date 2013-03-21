DiagramBuilder = require "DiagramBuilder"

class RobustnessDiagramBuilder extends DiagramBuilder
  constructor: (@diagram) ->


core = require "core"
if core.env.is_node
  module.exports = RobustnessDiagramBuilder
else
  core.exports RobustnessDiagramBuilder

