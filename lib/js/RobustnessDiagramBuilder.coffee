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

_icon = (name, k)->
  icon = new IconElement name, kind:k

RobustnessDiagramBuilder::actor = (opt)->
  if typeof opt is "string"
    @_diagram.append (a = _icon opt, "actor")
    return a
  else if typeof opt is "object"
    for k of opt
      if typeof (f = opt[k]) is "function"
        a = _icon k, "actor"
        b = f.apply this, []
        @_diagram.append(a).append(b)
        return a
  throw "unexpected: " + typeof opt

RobustnessDiagramBuilder::view = ->

RobustnessDiagramBuilder::controller= ->

RobustnessDiagramBuilder::entity = ->

core = require "core"
if core.env.is_node
  module.exports = RobustnessDiagramBuilder
else
  core.exports RobustnessDiagramBuilder

