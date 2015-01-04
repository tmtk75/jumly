DiagramBuilder = require "DiagramBuilder.coffee"
RobustnessDiagram = require "RobustnessDiagram.coffee"
IconElement = require "IconElement.coffee"
Relationship = require "Relationship.coffee"

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

module.exports = RobustnessDiagramBuilder
