max = (a, b) -> b - a
min = (a, b) -> a - b
$.choose = (nodes, ef, cmpf)-> $.map(nodes, ef).sort(cmpf)[0]
$.max = (nodes, ef)-> $.choose(nodes, ef, max)
$.min = (nodes, ef)-> $.choose(nodes, ef, min)
_fn = $.fn
_fn.choose = (ef, cmpf)-> $.choose(this, ef, cmpf)
_fn.max = (ef)-> $.max(this, ef)
_fn.min = (ef)-> $.min(this, ef)

# A specific iterator that picks up by 2 from this nodeset.
# f0: a callback has one argument like (e) -> to handle the 1st node.
# f1: a callback has two arguments like (a, b) -> to handle the nodes after 2nd node.
_fn.pickup2 = (f0, f1, f2) ->
  return this if @length is 0
  f0 prev = $(this[0])
  return this if @length is 1
  @slice(1).each (i, curr)=>
    curr = $ curr
    if f2? and (i + 1 is @length - 1)
      f2 prev, curr, i + 1
    else
      f1 prev, curr, i + 1
    prev = curr

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
        
_fn.cssAsInt = (name) -> a = @css(name); if a then parseInt a else 0

$.fn._d = (p)->
  e = @find(p).data "_self"
  a = e.offset()
  a.right = a.left + e.width() - 1
  a.bottom = a.top + e.height() - 1
  a.width = e.width()
  a.center = a.left + (Math.round e.width()/2)
  a.middle = a.top + (Math.round e.height()/2)
  a

