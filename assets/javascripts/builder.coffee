class DiagramBuilder extends JUMLY.DSLEvents_
  @selectHTMLScriptElements = (element)->
    $("script", element).not(".ignored")

DiagramBuilder::accept = (closure)->
  closure.apply this, []

DiagramBuilder::build = (text)->
  typename = this.constructor.name.replace(/^JUMLY/, "")
                                  .replace(/Diagram(Builder)?$/, "")
                                  .toLowerCase()
  @diagram = $.jumly ".#{typename}-diagram"
  @accept -> eval CoffeeScript.compile text
  @diagram

JUMLY.DiagramBuilder = DiagramBuilder

