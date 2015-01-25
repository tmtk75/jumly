Diagram = require "Diagram.coffee"
pos = require "position.coffee"

class ClassDiagram extends Diagram

ClassDiagram::member = (kind, clz, normval)->
  holder = clz.find(".#{kind}s")
  $(normval["#{kind}s"]).each (i, e)->
    id = "#{normval.id}-#{kind}-#{e}"
    throw new Error("Already exists #{e}") if holder.find(".#{e}").length > 0
    holder.append $("<li>").addClass(e).attr("id", id).html e

ClassDiagram::declare = (normval) ->
  clz = $.jumly ".class", normval
  if normval.stereotype
    clz.find(".stereotype").html normval.stereotype
  else
    clz.find(".stereotype").hide()
    
  @member(kind, clz, normval) for kind in ["attr", "method"]

  ref = @_regByRef_ normval.id, clz
  eval "#{ref} = clz"
  @append clz

ClassDiagram::preferredWidth = ->
  pos.mostLeftRight(@find(".class .icon")).width() + 16 ##WORKAROUND: 16 is magic number.

ClassDiagram::preferredHeight = ->
  @find(".class .icon").mostTopBottom().height()

ClassDiagram::compose = ->
  ## Resize for looks
  @find(".class .icon").each (i, e) ->
    e = $ e
    return null if e.width() > e.height()
    e.width e.height() * (1 + Math.sqrt 2)/2
  @width @preferredWidth()
  @height @preferredHeight()
  this


module.exports = ClassDiagram
