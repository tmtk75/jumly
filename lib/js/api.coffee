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

JUMLY.scan = ->
  $("body").find("*[data-jumly]").each (i, e)->
    $e = $(e)
    return if $e.data("jumly.evaluated") ## skip already evaluated ones
    code = (switch e.nodeName.toLowerCase()
              when "input", "textarea" then $e.val()
              else $e.text())
    d = JUMLY._compile code
    $e.after d
    JUMLY._layout d
    $e.data "jumly.evaluated", d
