HTMLElement = require "HTMLElement"

class SequenceInteraction extends HTMLElement
  constructor: (@_actor, @_actee)->
    super()

SequenceInteraction::_build_ = (div, props)->
  msg = jumly type:".message", ".interaction":this
  props[".message"] = msg  ## FIXME: Can I remove this?
  div.append(msg)

SequenceInteraction::interact = (obj) -> @awayfrom().interact obj
SequenceInteraction::forward = (obj) -> @toward()

SequenceInteraction::to = (func) ->
  occurrs = @gives(".occurrence")
  tee = occurrs.as(".actee")
  tor = occurrs.as(".actor")
  func(tee, tor)

SequenceInteraction::forwardTo = -> @gives(".occurrence").as ".actee"
SequenceInteraction::backwardTo = -> @gives(".occurrence").as ".actor"
SequenceInteraction::toward = -> @forwardTo()
SequenceInteraction::awayfrom = (obj) ->
  return @backwardTo() unless obj
  for e in @parents(".occurrence").not(".activated")
    e = $(e).self()
    return e if e?.gives(".object") is obj
  obj.activate()

SequenceInteraction::_compose_ = ->
  that = this
  src = @_actor
  dst = @_actee
  msg = that.find("> .message").data("_self")
  # Self-invokation case
  if @isToSelf()
    @_buildSelfInvocation src, dst, msg
    return

  # Determine the width of interaction for normal message
  w = src.offset().left - (dst.offset().left + $(".occurrence:eq(0)", that).width())
  if @hasClass("lost")
    msg.height dst.outerHeight()
  else if msg.isTowardLeft()
    w = dst.offset().left - (src.offset().left + $(".occurrence:eq(0)", that).width())
  msg.width(Math.abs(w))
     .offset(left:Math.min(src.offset().left, dst.offset().left))
     .repaint()

  # Locate the name of message
  # Normal message
  #TODO: Move this centering logic for name to .message class. 

  # Return message
  rmsg = $("> .message.return:last", that).self()
  if rmsg
    x = msg.offset().left
    actee = rmsg.gives ".actee"
    if actee
      newdst = rmsg._findOccurr actee
      unless newdst
        console.error "Not found occurrence for", actee
        throw new Error("Not found occurrence #{actee.html()}")
      w = dst.offset().left - newdst.offset().left
      x = Math.min dst.offset().left, newdst.offset().left
    rmsg.width(Math.abs w)
        .offset(left:x)
        .repaint(reverse:true)

SequenceInteraction::_buildSelfInvocation = (a, b, msg) ->
  w = @find(".occurrence:eq(0)").outerWidth()  ## It's based on the width of occurrence.
  dx = w*2
  dy = w*1
  b.css top:0 + dy          # Shift the actee occurrence to y-positive
  @css "padding-bottom":dy  # To expand the height of occurrence of actor

  msg.css(top:0)
     .width(b.width() + dx)
     .height(b.offset().top - msg.offset().top + dy + w/8)
     .offset left:b.offset().left
  
  msg.repaint self:true

  arrow = msg.find ".arrow"
  msg.find(".name").offset
      left: arrow.offset().left + arrow.outerWidth()
      top : arrow.offset().top

SequenceMessage = require "SequenceMessage"

SequenceInteraction::reply = (p) ->
    @addClass "reply"
    a = new SequenceMessage(this, p?[".actee"]) #jumly(type:".message", ".interaction":this, ".actee":p?[".actee"])
        .addClass("return")
        .insertAfter @children ".occurrence:eq(0)"
    if p?.name
        a.name p.name
    this

SequenceInteraction::fragment = (attrs, opts) ->
    SequenceFragment = require "SequenceFragment"
    frag = new SequenceFragment()
    frag.enclose(this)
   
SequenceInteraction::isToSelf = ->
    a = @_actor
    b = @_actee
    unless a && b
        return false
    a._actor is b._actor

SequenceInteraction::is_to_itself = -> @isToSelf()

core = require "core"
if core.env.is_node
  module.exports = SequenceInteraction
else
  core.exports SequenceInteraction

