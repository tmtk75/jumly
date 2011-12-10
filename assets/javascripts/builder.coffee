class DiagramBuilder
  @selectHTMLScriptElements = (element)-> $("script", element).not(".ignored")
  
  @new_ = (element)->
    new UsecaseDiagramBuilder

DiagramBuilder::build = (script)->
  tmp = "__#{new Date().getTime()}__"
  this[tmp] = ->
    eval CoffeeScript.compile script.text()
  this[tmp]()
  delete this.tmp

JUMLY =
  DiagramBuilder: DiagramBuilder

$.extend window.JUMLY, JUMLY


class UsecaseDiagramBuilder extends DiagramBuilder

UsecaseDiagramBuilder::boundary = ->