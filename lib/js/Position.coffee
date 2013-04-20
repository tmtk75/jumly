self = require: JUMLY.require

class Position
  constructor: (@attrs)->
    @div = $("<div>").addClass(@attrs.css)
                     .css position:"absolute"
Position::_coordinate = (target)->
  if @attrs.coordinate
    @attrs.coordinate.append @div
  else
    target.after @div
    
class PositionRightLeft extends Position
class PositionLeftRight extends Position
class PositionLeft      extends Position
class PositionTop       extends Position

PositionRightLeft::apply = ->
  src = @attrs.src
  @_coordinate src
  @div.offset left:src.offset().left + src.outerWidth()
  @attrs.dst.offset left:@div.offset().left + @div.outerWidth()

PositionLeftRight::apply = ->
  src = @attrs.src
  dst = @attrs.dst
  @_coordinate src
  @div.offset left:src.offset().left - @div.outerWidth()
  @attrs.dst.offset left:@div.offset().left - @attrs.dst.outerWidth()

PositionLeft::apply = ->
  dst = @attrs.dst
  @_coordinate dst
  @attrs.dst.offset left:(@div.offset().left + @div.outerWidth())

PositionTop::apply = ->
  dst = @attrs.dst
  @_coordinate dst
  @attrs.dst.offset top:(@div.offset().top + @div.outerHeight())


Position.RightLeft = PositionRightLeft
Position.LeftRight = PositionLeftRight
Position.Left      = PositionLeft
Position.Top       = PositionTop


core = self.require "core"
if core.env.is_node
  module.exports = Position
else
  core.exports Position
