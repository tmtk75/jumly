HTMLElement = require "HTMLElement"

class SequenceOccurrence  extends HTMLElement
  constructor: (@_actor)->
    super()

core = require "core"
SequenceInteraction = require "SequenceInteraction"

SequenceOccurrence::interact = (actor, opts) ->
    _as = core.lang._as
    if opts?.stereotype is ".lost"
        occurr = new SequenceOccurrence().addClass "icon"
        iact   = new SequenceInteraction this, occurr
        iact.addClass "lost"
    else if opts?.stereotype is ".destroy"
        #NOTE: Destroy message building
    else if actor?.stereotype is ".alt"
        SequenceFragment = require "SequenceFragment"
        alt = new SequenceFragment name:"alt"
        alt.alter this, opts
        return this
    else
      occurr = new SequenceOccurrence actor
      iact = new SequenceInteraction this, occurr
    iact.append(occurr).appendTo this

SequenceOccurrence::create = (objsrc) ->
  SequenceObject = require "SequenceObject"
  obj = new SequenceObject objsrc.name
  obj.attr "id", objsrc.id
  @parents(".sequence-diagram").self()[core._to_ref objsrc.id] = obj
  @_actor.parent().append obj
  iact = (@interact obj).stereotype "create"
  iact

SequenceOccurrence::_move_horizontally =->
  if @parent().hasClass "lost"
    @offset left:@parents(".diagram").find(".object").mostLeftRight().right
    return this 
  if not @isOnOccurrence()
    left = @_actor.offset().left + (@_actor.width() - @width())/2
  else
    left = @_parent_occurr().offset().left
  left += @width()*@_shift_to_parent()/2
  @offset left:left

SequenceOccurrence::isOnOccurrence =->
  not (@_parent_occurr() is null)

SequenceOccurrence::_parent_occurr = ->
    occurrs = @parents ".occurrence"
    return null if occurrs.length is 0

    for i in [0..occurrs.length - 1]
      if @_actor is $(occurrs[i]).data("_self")._actor
        return $(occurrs[i]).data("_self")
    null

SequenceOccurrence::_shift_to_parent = ->
    return 0 if not @isOnOccurrence()
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
        return a    if a.gives(".object") is obj
        return f a
    f this

SequenceOccurrence::destroy = (actee) ->
    #NOTE: expecting interface
    #return @interact(actee, {stereotype:"destroy"})
    #Tentative deprecated implementation.
    occur = @interact(actee)
                .stereotype("destroy")
                .data("_self")._actee
    if occur.isOnOccurrence()
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
