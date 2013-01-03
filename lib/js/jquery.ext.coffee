_max = (nodes, ef)-> _choose(nodes, ef, (a, b)-> b - a)
_min = (nodes, ef)-> _choose(nodes, ef, (a, b)-> a - b)
_choose = (nodes, ef, cmpf)-> $.map(nodes, ef).sort(cmpf)[0]
$.fn.choose = (ef, cmpf)-> _choose(this, ef, cmpf)
$.fn.max = (ef)-> _max(this, ef)
$.fn.min = (ef)-> _min(this, ef)

$.fn.outerBottom = -> @offset().top + @outerHeight() - 1

$.fn.mostLeftRight = ->
  left : @min (e)-> $(e).offset().left
  right: @max (e)->
    t = $(e).offset().left + $(e).outerWidth()
    if t - 1 < 0 then 0 else t - 1
  width: -> if @right? and @left? then @right - @left + 1 else 0

$.fn.mostTopBottom = ->
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
