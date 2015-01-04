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

  selfEach: ($e, f)-> $e.each (i, e)->
    e = utils.self $(e)
    throw new Error("_self have nothing ", e) unless e?
    f e
    this

  # A specific iterator that picks up by 2 from this nodeset.
  # f0: a callback has one argument like (e) -> to handle the 1st node.
  # f1: a callback has two arguments like (a, b) -> to handle the nodes after 2nd node.
  pickup2: ($e, f0, f1, f2) ->
    return $e if $e.length is 0
    f0 prev = $($e[0])
    return $e if $e.length is 1
    $e.slice(1).each (i, curr)=>
      curr = $ curr
      if f2? and (i + 1 is $e.length - 1)
        f2 prev, curr, i + 1
      else
        f1 prev, curr, i + 1
      prev = curr
  
  ## This is wrap feature keeping own instance, jQuery.wrap makes child node duplicated.
  swallow: ($e, _, f) ->
    f = f or $.fn.append
    if _.length is 1
      if _.index() is 0 then _.parent().prepend $e else $e.insertAfter _.prev()
    else
      #NOTE: In order to solve the case for object-lane. You use closure if you want flexibility.
      if _.index() is 0 then $e.prependTo $(_[0]).parent() else $e.insertBefore _[0]
    $e.append _.detach()
    $e

module.exports = utils
