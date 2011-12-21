max = (a, b) -> b - a
min = (a, b) -> a - b
jQuery.choose = (nodes, ef, cmpf) -> jQuery.map(nodes, ef).sort(cmpf)[0]
jQuery.max = (nodes, ef) -> jQuery.choose(nodes, ef, max)
jQuery.min = (nodes, ef) -> jQuery.choose(nodes, ef, min)
jQuery.fn.max = (ef) -> jQuery.max(this, ef)
jQuery.fn.min = (ef) -> jQuery.min(this, ef)

# A specific iterator that picks up by 2 from this nodeset.
# f0: a callback has one argument like (e) -> to handle the 1st node.
# f1: a callback has two arguments like (a, b) -> to handle the nodes after 2nd node.
jQuery.fn.pickup2 = (f0, f1, f2) ->
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

# This is wrap feature keeping own instance, wrop is that node is duplicated
jQuery.fn.swallow = (_, f) ->
	f = f or jQuery.fn.append
	if _.length is 1
		if _.index() is 0
			_.parent().prepend this
		else
			@insertAfter _.prev()
	else
		#NOTE: In order to solve the case for object-lane.
		#      You use closure if you want flexibility.
		if _.index() is 0
			@prependTo $(_[0]).parent()
		else
			@insertBefore _[0]
	@append _.detach()
	this

jQuery.fn.outerRight = ->
    @offset().left + @outerWidth()

jQuery.fn.mostLeftRight = ->
    left : @min (e) -> $(e).offset().left
    right: @max (e) ->
        t = $(e).offset().left + $(e).outerWidth()
        if t - 1 < 0 then 0 else t - 1
    width: ->
        if @right? and @left?
            @right - @left + 1
        else
            0

jQuery.fn.mostTopBottom = ->
    top   : @min (e) -> $(e).offset().top
    bottom: @max (e) ->
        t = $(e).offset().top + $(e).outerHeight()
        if t - 1 < 0 then 0 else t - 1
    height: ->
        if @top? and @bottom?
            @bottom - @top + 1
        else
            0

jQuery.fn.align = (dir, base) ->
	base = $(base || this[0])
	switch dir
	    when 'bottom', 'south'
	        f = (i, e) -> top:base.outerHeight() - $(e).outerHeight()
        else
            throw "unspported: " + dir
    @each (i, e) -> $(e).offset f(i, e)

String.prototype.toInt = ->
    if this.length > 0
        parseInt this
    else
        0

##
## Alignment for left, right, above, below.
##
_align = (me, base, klass) ->
    me.addClass klass
    pos = base.offset()
    switch klass
        when "left"  then pos.left -= me.outerWidth()
        when "right" then pos.left += base.outerWidth()
        when "above" then pos.top  -= me.outerHeight()
        when "below" then pos.top  += base.outerHeight()
    me.offset(pos)

jQuery.fn.alignAt = (base, pos) -> _align(this, base, pos)


##
class Logger
  @out = (cate, lv, msg)-> console.log "#{cate}:#{lv} --", msg
  @err = (cate, lv, msg)-> console.error "#{cate}:#{lv} --", msg
  constructor: (@category)->
Logger::log = (lv, msg)->
  Logger.out @category, lv, msg
Logger::debug = (s)-> @log "debug", s
Logger::info  = (s)-> @log "info", s
Logger::error = (s)-> @err @category, "error", s
$.logger = (category)-> new Logger category

##
$.kindof = (that)->
  return 'Null' if that is null
  return 'Undefined' if that is undefined 
  tc = that.constructor
  toName = (f)-> if 'name' in f then f.name else (''+f).replace(/^function\s+([^\(]*)[\S\s]+$/im, '$1')
  if typeof(tc) is 'function' then toName(tc) else tc # [object HTMLDocumentConstructor]
