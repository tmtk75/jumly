class DiagramBuilder extends JUMLY.DSLEvents_
  @selectHTMLScriptElements = (element)->
    $("script", element).not(".ignored")

DiagramBuilder::accept = (closure)->
  closure.apply this, []

DiagramBuilder::build = (text)->
  a = this.constructor.name.replace(/^JUMLY/, "").replace(/DiagramBuilder$/, "")
  console.log this.constructor.name, "name:", a
  @diagram = null
  @accept eval CoffeeScript.compile text
  @diagram

JUMLY.DiagramBuilder = DiagramBuilder

