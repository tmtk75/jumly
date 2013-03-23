DiagramLayout = require "DiagramLayout"

class RobustnessDiagramLayout extends DiagramLayout

core = require "core"
if core.env.is_node
  module.exports = RobustnessDiagramLayout
else
  core.exports RobustnessDiagramLayout
