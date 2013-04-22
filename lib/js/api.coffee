###
Some public APIs which are experimental
###
JUMLY._compile = (code)->
  builder = new (JUMLY.require "SequenceDiagramBuilder")
  builder.build code

JUMLY._layout = (doc)->
  layout  = new (JUMLY.require "SequenceDiagramLayout")
  layout.layout doc

JUMLY.eval = (code, opts)->
  doc = @_compile code
  $(opts.into).html doc
  @_layout doc
