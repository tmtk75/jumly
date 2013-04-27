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
_mkey = "jumly" # meta data key
JUMLY.eval = ($src, opts)->
  d = @_compile $src.text()
  if typeof opts is "function"
    opts d, $src
  else if typeof opts is "object"
    throw "missing `into`" unless opts.into
    $(opts.into).html d
  else
    throw "no idea to place a new diagram."

  @_layout d
  return d if typeof $src is "string"

  meta = $src.data _mkey
  if meta is undefined
    $src.data _mkey, meta = {}
  else if typeof meta is "string"
    $src.data _mkey, meta = type:meta
  else if typeof meta is "object"
    meta # nop
  else
    throw "unknwon type: #{typeof meta}"

  $.extend meta, "dst":d
  d.data _mkey, "src":$src

###
  provider: function or jQuery nodeset
            if funciton, it returns jQuery nodeset
  opts:
    placer: function
            to return the 2nd argument of JUMLY.eval.
###
_opts =
  placer: (d, $e)-> $e.after d

JUMLY.scan = (scope = document, opts)->
  nodes = $(scope)
  p = $.extend {}, _opts, opts
  nodes.each (i, e)->
    $e = $(e)
    if dst = $e.data(_mkey)?.dst
      if p.synchronize
        JUMLY.eval $e, into:dst
      ## skip already evaluated ones if no synchronize
      return
    JUMLY.eval $e, p.placer

