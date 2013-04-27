###
Some public APIs which are experimental
###
_type = "text/jumly+sequence"

JUMLY._compile = (code, type = _type)->
  switch type
    when "text/jumly+sequence"   then builder = new (JUMLY.require "SequenceDiagramBuilder")
    when "text/jumly+robustness" then builder = new (JUMLY.require "RobustnessDiagramBuilder")
    else throw "unknown type: #{type}"
  builder.build code

JUMLY._layout = (doc, type = _type)->
  switch type
    when "text/jumly+sequence"   then layout = new (JUMLY.require "SequenceDiagramLayout")
    when "text/jumly+robustness" then layout = new (JUMLY.require "RobustnessDiagramLayout")
    else throw "unknown type: #{type}"
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
  meta = $src.data _mkey
  if meta is undefined
    $src.data _mkey, meta = {}
  else if typeof meta is "string"
    $src.data _mkey, meta = type:meta
  else if typeof meta is "object"
    meta # nop
  else
    throw "unknown type: #{typeof meta}"
  meta.type = $src.attr("type") if $src[0].nodeName.toLowerCase() is "script"

  d = @_compile $src.text(), meta.type
  if typeof opts is "function"
    opts d, $src
  else if typeof opts is "object"
    throw "missing `into`" unless opts.into
    $(opts.into).html d
  else
    throw "no idea to place a new diagram."

  @_layout d, meta.type

  $.extend meta, "dst":d
  d.data _mkey, "src":$src

###
  provider: function or jQuery nodeset
            if funciton, it returns jQuery nodeset
  opts:
    finder: function
            to find candidated nodes
    filter: function
            to filter candiates to eval
    placer: function
            to return the 2nd argument of JUMLY.eval.
###
_opts =
  finder: ($n)-> $n.find "script, *[data-jumly]"
  filter: (i, n)->
            if n.nodeName.toLowerCase() is "script" and type = $(n).attr("type")
              type.match /text\/jumly\+.*/
            else
              true
  placer: (d, $e)-> $e.after d

JUMLY.scan = (scope = document, opts)->
  p = $.extend {}, _opts, opts
  p.finder($(scope)).filter(p.filter).each (i, e)->
    $e = $(e)
    if dst = $e.data(_mkey)?.dst
      if p.synchronize
        JUMLY.eval $e, into:dst
      ## skip already evaluated ones if no synchronize
      return
    JUMLY.eval $e, p.placer

