$ = require "jquery"

_outerBottom = ($e)-> $e.offset().top + $e.outerHeight() - 1

_choose = (nodes, ef, cmpf)-> $.map(nodes, ef).sort(cmpf)[0]

utils =
  max: (nodes, ef)-> _choose(nodes, ef, (a, b)-> b - a)
  min: (nodes, ef)-> _choose(nodes, ef, (a, b)-> a - b)

  mostLeftRight: (objs, margin)->
    left : @min objs, (e)-> $(e).offset().left - (if margin then (parseInt $(e).css("margin-left")) else 0)
    right: @max objs, (e)->
      t = $(e).offset().left + $(e).outerWidth() + (if margin then (parseInt $(e).css("margin-right")) else 0)
      if t - 1 < 0 then 0 else t - 1
    width: -> if @right? and @left? then @right - @left + 1 else 0

  mostTopBottom: (objs, margin)->
    top   : @min objs, (e)-> $(e).offset().top - (if margin then (parseInt $(e).css("margin-top")) else 0)
    bottom: @max objs, (e)->
      t = $(e).offset().top + $(e).outerHeight() + (if margin then (parseInt $(e).css("margin-bottom")) else 0)
      if t - 1 < 0 then 0 else t - 1
    height:-> if @top? and @bottom? then @bottom - @top + 1 else 0

  outerBottom: _outerBottom

  self: ($e)-> $e.data "_self"

module.exports = utils
