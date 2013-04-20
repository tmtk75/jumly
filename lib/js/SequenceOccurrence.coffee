self = require: JUMLY.require
HTMLElement = self.require "HTMLElement"
utils = self.require "jquery.ext"

class SequenceOccurrence  extends HTMLElement
  constructor: (@_actor)->
    super()

core = self.require "core"
SequenceInteraction = self.require "SequenceInteraction"

SequenceOccurrence::interact = (actor, acts) ->
    if acts?.stereotype is ".lost"
        occurr = new SequenceOccurrence().addClass "icon"
        iact   = new SequenceInteraction this, occurr
        iact.addClass "lost"
    else if acts?.stereotype is ".destroy"
        #NOTE: Destroy message building
    else if actor?.stereotype is ".alt"
        SequenceFragment = self.require "SequenceFragment"
        alt = new SequenceFragment "alt"
        alt.alter this, acts
        return this
    else
      occurr = new SequenceOccurrence actor
      iact = new SequenceInteraction this, occurr
    if actor is iact._actor._actor
      iact.addClass "self"
    iact.append(occurr).appendTo this
    iact

SequenceOccurrence::create = (objsrc) ->
  SequenceParticipant = self.require "SequenceParticipant"
  obj = new SequenceParticipant(objsrc.name)
              .addClass "created-by"
  @_actor.parent().append obj
  iact = (@interact obj)
           .addClass("creating")
           .find(".message")
           .addClass("create")
           .end()

SequenceOccurrence::_move_horizontally = ->
  if @parent().hasClass "lost"
    offset left:utils.mostLeftRight(@parents(".diagram").find(".participant")).right
    return this
  if not @is_on_another()
    left = @_actor.offset().left + (@_actor.preferred_width() - @width())/2
  else
    left = @_parent_occurr().offset().left
  left += @width()*@_shift_to_parent()/2
  @offset left:left

SequenceOccurrence::is_on_another =->
  not (@_parent_occurr() is null)

SequenceOccurrence::_parent_occurr = ->
    occurrs = @parents ".occurrence"
    return null if occurrs.length is 0

    for i in [0..occurrs.length - 1]
      if @_actor is $(occurrs[i]).data("_self")._actor
        return $(occurrs[i]).data("_self")
    null

SequenceOccurrence::_shift_to_parent = ->
    return 0 if not @is_on_another()
    # find a message contained in the same interaction together.
    a = @parent().find(".message:eq(0)").data("_self")
    return 0  if a is undefined
    return -1 if a.isTowardRight()
    return 1  if a.isTowardLeft()
    # in case of self-invokation below
    return 1

SequenceOccurrence::preceding = (obj) ->
    f = (ll) ->
        a = jumly(ll.parents ".occurrence:eq(0)")[0]
        return null if !a
        return a    if a.gives(".participant") is obj
        return f a
    f this

SequenceOccurrence::destroy = (actee) ->
    #NOTE: expecting interface
    #return @interact(actee, {stereotype:"destroy"})
    #Tentative deprecated implementation.
    occur = @interact(actee)
                #.stereotype("destroy")
                .data("_self")._actee
    if occur.is_on_another()
        occur = occur._parent_occurr()
		
    $("<div>").addClass("stop")
              .append($("<div>").addClass("icon")
                                .addClass("square")
                                .addClass("cross"))
              .insertAfter(occur)
    occur

if core.env.is_node
  module.exports = SequenceOccurrence
else
  core.exports SequenceOccurrence
