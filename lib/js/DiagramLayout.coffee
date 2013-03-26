self = require: unless typeof require is "undefined" then require else JUMLY.require

class DiagramLayout

DiagramLayout::layout = (diagram)->
  @diagram = diagram
  @_layout?()

core = self.require "core"
if core.env.is_node
  module.exports = DiagramLayout
else
  core.exports DiagramLayout
