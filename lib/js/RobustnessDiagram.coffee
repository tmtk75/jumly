HTMLElement = require "HTMLElement"

class RobustnessDiagram extends HTMLElement

core = require "core"
if core.env.is_node
  module.exports = RobustnessDiagram
else
  core.exports RobustnessDiagram
