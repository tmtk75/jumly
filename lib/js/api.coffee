###
Some public APIs which are experimental
###
_type = "text/jumly+sequence"

_t2l =  # type 2 logic
  "text/jumly+sequence":
    builder: "SequenceDiagramBuilder"
    layout:  "SequenceDiagramLayout"
  "text/jumly+robustness":
    builder: "RobustnessDiagramBuilder"
    layout:  "RobustnessDiagramLayout"

JUMLY._compile = (code, type = _type)->
  throw "unknown type: #{type}" unless _t2l[type]
  (new (JUMLY.require _t2l[type].builder)).build code

JUMLY._layout = (doc, type = _type)->
  throw "unknown type: #{type}" unless _t2l[type]
  (new (JUMLY.require _t2l[type].layout)).layout doc

## returns JUMLY meta object
_to_meta = ($src)->
  meta = $src.data _mkey
  if meta is undefined
    $src.data _mkey, meta = {}
  else if typeof meta is "string"
    $src.data _mkey, meta = type:meta
  else if typeof meta is "object"
    meta # nop
  else
    throw "unknown type: #{typeof meta}"
  meta.type = $src.attr("type") if _is_script $src[0]
  meta

## returns true if n is <scipt>
_is_script = (n)-> n.nodeName.toLowerCase() is "script"

## returns value of node
_val = (s)->
  switch s[0].nodeName.toLowerCase()
    when "textarea", "input" then s.val()
    else s.text()

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
  meta = _to_meta $src

  d = @_compile _val($src), meta.type
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
  scope: DOM | jQuery nodeset
         nodeset to scan
  opts:
    finder: function
            to find candidated nodes
    placer: function
            to put new created diagram into somewhere
###
_opts =
  finder: ($n)->
            nodes = $n.find "script, *[data-jumly]"
            filter = (n)-> unless _is_script n
                             true
                           else
                             $(n).attr("type")?.match /text\/jumly\+.*/
            e for e in nodes when filter(e)
  placer: (d, $e)-> $e.after d

JUMLY.scan = (scope = document, opts)->
  p = $.extend {}, _opts, opts
  for e in p.finder($ scope)
    $e = $(e)
    if dst = $e.data(_mkey)?.dst
      if p.synchronize
        JUMLY.eval $e, into:dst
      ## skip already evaluated ones if no synchronize
    else
      JUMLY.eval $e, p.placer

