self = require: JUMLY.require
DiagramBuilder = self.require "DiagramBuilder"
RobustnessDiagram = self.require "RobustnessDiagram"
IconElement = self.require "IconElement"
Relationship = self.require "Relationship"

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

core = self.require "core"

RobustnessDiagramBuilder::_node = (opt, kind)->
  if typeof opt is "string"
    @_diagram.append (a = @_diagram._node_of opt, kind)
    return a
  else if typeof opt is "object"
    for k of opt
      if typeof (f = opt[k]) is "function"
        a = @_diagram._node_of k, kind
        b = f.apply this, []
        @_diagram.append(a).append(b)
        @_diagram.append new Relationship("", src:a, dst:b)
        return a
  throw "unexpected: " + typeof opt

RobustnessDiagramBuilder::actor = (opt)-> @_node opt, "actor"

RobustnessDiagramBuilder::view = (opt)-> @_node opt, "view"

RobustnessDiagramBuilder::controller= (opt)-> @_node opt, "controller"

RobustnessDiagramBuilder::entity = (opt)-> @_node opt, "entity"

core = self.require "core"
if core.env.is_node
  module.exports = RobustnessDiagramBuilder
else
  core.exports RobustnessDiagramBuilder

