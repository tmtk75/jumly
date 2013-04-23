###
Some public APIs which are experimental
###
JUMLY._compile = (code)->
  builder = new (JUMLY.require "SequenceDiagramBuilder")
  builder.build code

JUMLY._layout = (doc)->
  layout  = new (JUMLY.require "SequenceDiagramLayout")
  layout.layout doc

###
  node: a jQuery node
        To get jumly script from it.

  opts: function or object
        If object, it must have "into" property which value is
        acceptable by $() like selector, dom and jQuery object.

        If function, it must return a function in order to put a new diagram node
        into the document. And also it should return the node which the new function put into.
###
JUMLY.eval = ($node, opts)->
  d = @_compile $node.text()
  if typeof opts is "function"
    opts d
  else if typeof opts is "object"
    $(opts.into).html d
  @_layout d
  $node.data "jumly.diagram", d
  d.data "jumly.src", $node

###
  placer  : function
            to return the 2nd argument of JUMLY.eval.

  provider: function
            to return jQuery node set which have jumly code
###
_placer = ($e)-> (d)-> $e.after d
_provider = -> $("body").find("*[data-jumly]")
JUMLY.scan = (placer = _placer, provider = _provider)->
  provider().each (i, e)->
    $e = $(e)
    return if $e.data("jumly.diagram") ## skip already evaluated ones
    JUMLY.eval $e, placer($e)
