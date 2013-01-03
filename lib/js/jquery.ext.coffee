max = (a, b) -> b - a
min = (a, b) -> a - b
$.choose = (nodes, ef, cmpf)-> $.map(nodes, ef).sort(cmpf)[0]
$.max = (nodes, ef)-> $.choose(nodes, ef, max)
$.min = (nodes, ef)-> $.choose(nodes, ef, min)
_fn = $.fn
_fn.choose = (ef, cmpf)-> $.choose(this, ef, cmpf)
_fn.max = (ef)-> $.max(this, ef)
_fn.min = (ef)-> $.min(this, ef)

_fn.outerRight = -> @offset().left + @outerWidth()
_fn.right = -> @offset().left + @width() - 1
_fn.outerBottom = -> @offset().top + @outerHeight() - 1

_fn.mostLeftRight = ->
  left : @min (e)-> $(e).offset().left
  right: @max (e)->
    t = $(e).offset().left + $(e).outerWidth()
    if t - 1 < 0 then 0 else t - 1
  width: -> if @right? and @left? then @right - @left + 1 else 0

_fn.mostTopBottom = ->
  top   : @min (e)-> $(e).offset().top
  bottom: @max (e)->
    t = $(e).offset().top + $(e).outerHeight()
    if t - 1 < 0 then 0 else t - 1
  height:-> if @top? and @bottom? then @bottom - @top + 1 else 0
        
$.fold = (list, init, func)->
  l = init
  for e in list
    l = func.apply null, [l, e]
  l

$.reduce = (list, func)->
  return undefined if list.length is 0
  $.fold list[1..], list[0], func
