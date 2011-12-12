class DiagramBuilder
  @selectHTMLScriptElements = (element)-> $("script", element).not(".ignored")

DiagramBuilder::accept = (closure)->
  closure.apply this, []

JUMLY.DiagramBuilder = DiagramBuilder

