HTMLElement = require "HTMLElement.coffee"
Diagram = require "Diagram.coffee"

class SequenceDiagram extends Diagram
  constructor: ->
    super()

#JUMLY.def ".sequence-diagram", SequenceDiagram
    
SequenceDiagram::gives = (query)->
  e = @find(query)
  f = jumly.lang._of e, query
  {of: f}

prefs_ =
    WIDTH : null
    HEIGHT: 50


module.exports = SequenceDiagram
