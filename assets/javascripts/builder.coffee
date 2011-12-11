class DiagramBuilder
  @selectHTMLScriptElements = (element)-> $("script", element).not(".ignored")
  
  @new_ = (element)->
    new UsecaseDiagramBuilder

DiagramBuilder::build = (script)->
  @diagram = $.jumly ".use-case-diagram"
  tmp = "__#{new Date().getTime()}__"
  this[tmp] = ->
    eval CoffeeScript.compile script.text()
  this[tmp]()
  delete this[tmp]
  @diagram

ns =
  DiagramBuilder: DiagramBuilder

$.extend window.JUMLY, ns


class UsecaseDiagramBuilder extends DiagramBuilder

UsecaseDiagramBuilder::boundary = (jyval, next)->
  a = JUMLY.Identity.normalize jyval
  eval "#{a.id} = a"
  next.apply this, []

UsecaseDiagramBuilder::usecase = (jyval)->
  a = JUMLY.Identity.normalize jyval
  eval "#{a.id} = a"

UsecaseDiagramBuilder::actor = (jyval)->
  a = JUMLY.Identity.normalize jyval
  eval "#{a.id} = a"
