$ = require "jquery"
HTMLElement = require "HTMLElement.coffee"
utils = require "position.coffee"

class SequenceFragment extends HTMLElement
  constructor: (args)->
    super args, (me)->
      me.append($("<div>").addClass("header")
                          .append($("<div>").addClass("name"))
                          .append($("<div>").addClass("condition")))

  ## This is wrap feature keeping own instance, jQuery.wrap makes child node duplicated.
swallow = ($e, _, f) ->
    f = f or $.fn.append
    if _.length is 1
      if _.index() is 0 then _.parent().prepend $e else $e.insertAfter _.prev()
    else
      #NOTE: In order to solve the case for object-lane. You use closure if you want flexibility.
      if _.index() is 0 then $e.prependTo $(_[0]).parent() else $e.insertBefore _[0]
    $e.append _.detach()
    $e

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
    swallow(this, _)
    this

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

module.exports = SequenceFragment
