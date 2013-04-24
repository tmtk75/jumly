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

  opts: function | object
        If object, it must have "into" property which value is
        acceptable by $() like selector, dom and jQuery object.

        If function, it must return a function in order to put
        a new diagram node into the document.
        1st arg is the diagram node, 2nd arg is jQuery object
        having the source jumly code.
###
JUMLY.eval = ($node, opts)->
  d = @_compile $node.text()
  if typeof opts is "function"
    opts d, $node
  else if typeof opts is "object"
    $(opts.into).html d
  @_layout d
  $node.data "jumly.diagram", d
  d.data "jumly.src", $node

###
  provider: function or jQuery nodeset
            if funciton, it returns jQuery nodeset
  opts:
    finder: function
            to return nodeset which text() returns jumly code

    placer: function
            to return the 2nd argument of JUMLY.eval.
###
_provider = -> $("body")
_opts =
  finder: ($nodes)-> $nodes.find("*[data-jumly]")
  placer: (d, $e)-> $e.after d

JUMLY.scan = (provider = _provider, opts)->
  nodes = (if typeof provider is "function"
             provider()
           else unless provider
             _provider()
           else
             provider)
  p = $.extend {}, _opts, opts
  p.finder(nodes).each (i, e)->
    $e = $(e)
    return if $e.data("jumly.diagram") ## skip already evaluated ones
    JUMLY.eval $e, p.placer
