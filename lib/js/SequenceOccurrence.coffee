HTMLElement = require "HTMLElement"

class JUMLYOccurrence  extends HTMLElement

JUMLYOccurrence::interact = (_, opts) ->
    _as = jumly.lang._as
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
        occurr = jumly type:".occurrence", ".object":_
        iact   = jumly
                    "type"       : ".interaction"
                    ".occurrence": _as(".actor":this, ".actee":occurr)
                    ".object"    : _as(".actor":@gives(".object"), ".actee":_)
                    ".actor"     : this
                    ".actee"     : occurr
    iact.append(occurr).appendTo this
    iact

JUMLYOccurrence::create = (objsrc) ->
  obj = jumly ".object", objsrc.name
  obj.attr "id", objsrc.id
  @parents(".sequence-diagram").self()[JUMLY.Naming.toRef objsrc.id] = obj
  @gives(".object").parent().append obj
  iact = (@interact obj).stereotype "create"
  iact

JUMLYOccurrence::moveHorizontally =->
  if @parent().hasClass "lost"
    @offset left:@parents(".diagram").find(".object").mostLeftRight().right
    return this 
  if not @isOnOccurrence()
    left = @gives(".object").offset().left + (@gives(".object").width() - @width())/2
  else
    left = @parentOccurrence().offset().left
  left += @width()*@shiftToParent()/2
  @offset left:left

JUMLYOccurrence::isOnOccurrence =-> not (@parentOccurrence() is null)

JUMLYOccurrence::parentOccurrence = ->
    lls = jumly(@parents(".occurrence"))
    return null if lls.length is 0

    for i in [0..lls.length - 1]
        if @gives(".object") is lls[i].gives(".object")
            return lls[i]
    null

JUMLYOccurrence::shiftToParent = ->
    return 0 if not @isOnOccurrence()
    # find a message contained in the same interaction together.
    a = jumly(@parent().find ".message:eq(0)")[0]
    return 0  if a is undefined
    return -1 if a.isTowardRight()
    return 1  if a.isTowardLeft()
    # in case of self-invokation below
    return 1

JUMLYOccurrence::preceding = (obj) ->
    f = (ll) ->
        a = jumly(ll.parents ".occurrence:eq(0)")[0]
        return null if !a
        return a    if a.gives(".object") is obj
        return f a
    f this

JUMLYOccurrence::destroy = (actee) ->
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

core = require "core"
if core.env.is_node
  module.exports = JUMLYOccurrence
else
  core.exports JUMLYOccurrence
