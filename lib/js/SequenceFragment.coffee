HTMLElement = require "HTMLElement"

class SequenceFragment extends HTMLElement
  constructor: (args)->
    super args, (me)->
      me.append($("<div>").addClass("header")
                          .append($("<div>").addClass("name"))
                          .append($("<div>").addClass("condition")))

SequenceFragment::enclose = (_) ->
    if not _? or _.length is 0
        throw "SequenceFragment::enclose arguments are empty."
    if _.length > 1  # pre-condition: all nodes have same parent.
        a = $(_[0]).parent()[0]
        for i in [1 .. _.length - 1]
            b = $(_[i]).parent()[0]
            unless a is b
                throw {message:"different parent", nodes:[a, b]}
    if _.parent is undefined
        return this
    @swallow(_)
    this

SequenceFragment::extendWidth = (opts) ->
    frag = this
    dlw = opts?.left
    drw = opts?.right
    dlw ?= 0
    drw ?= 0
    frag.css("position", "relative")
        .css("left", -dlw)
        .width(frag.width() + dlw/2)
        .find("> .interaction")
           .css("margin-left", dlw)
    frag.width(frag.outerWidth() + drw)

SequenceFragment::alter = (occurr, acts) ->
    alt = this
    alt.addClass("alt")
       .find(".condition").remove()
    occurr.append alt
    for name of acts
        nodes = acts[name]()
        continue if nodes.length is 0
        alt.append($("<div>").addClass("condition").html name)
        alt.append(nodes)
        alt.append $("<div>").addClass("divider")
    alt.find(".divider:last").remove()
    alt

core = require "core"
if core.env.is_node
  module.exports = SequenceFragment
else
  core.exports SequenceFragment
