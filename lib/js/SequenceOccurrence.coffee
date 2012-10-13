HTMLElement = require "HTMLElement"

class SequenceOccurrence  extends HTMLElement

core = require "core"
SequenceInteraction = require "SequenceInteraction"

SequenceOccurrence::interact = (_, opts) ->
    _as = core.lang._as
    if opts?.stereotype is ".lost"
        occurr = jumly(type:".occurrence").addClass "icon"
        iact   = jumly type:".interaction", ".occurrence":_as(".actor":this, ".actee":occurr), ".actor":this, ".actee":occurr
        iact.addClass "lost"
    else if opts?.stereotype is ".destroy"
        #NOTE: Destroy message building
    else if _?.stereotype is ".alt"
        alt = jumly ".fragment", name:"alt"
        alt.alter this, opts
        return this
    else
      occurr = new SequenceOccurrence
      iact = new SequenceInteraction this, occurr
    iact.append(occurr).appendTo this

SequenceOccurrence::create = (objsrc) ->
  obj = jumly ".object", objsrc.name
  obj.attr "id", objsrc.id
  @parents(".sequence-diagram").self()[JUMLY.Naming.toRef objsrc.id] = obj
  @gives(".object").parent().append obj
  iact = (@interact obj).stereotype "create"
  iact

SequenceOccurrence::moveHorizontally =->
  if @parent().hasClass "lost"
    @offset left:@parents(".diagram").find(".object").mostLeftRight().right
    return this 
  if not @isOnOccurrence()
    left = @gives(".object").offset().left + (@gives(".object").width() - @width())/2
  else
    left = @parentOccurrence().offset().left
  left += @width()*@shiftToParent()/2
  @offset left:left

SequenceOccurrence::isOnOccurrence =-> not (@parentOccurrence() is null)

SequenceOccurrence::parentOccurrence = ->
    lls = jumly(@parents(".occurrence"))
    return null if lls.length is 0

    for i in [0..lls.length - 1]
        if @gives(".object") is lls[i].gives(".object")
            return lls[i]
    null

SequenceOccurrence::shiftToParent = ->
    return 0 if not @isOnOccurrence()
    # find a message contained in the same interaction together.
    a = jumly(@parent().find ".message:eq(0)")[0]
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
                .gives(".occurrence").as(".actee")
    if occur.isOnOccurrence()
        occur = occur.parentOccurrence()
		
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
