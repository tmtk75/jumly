class JUMLYPosition
  constructor: (@attrs)->
    @div = $("<div>").addClass(@attrs.css)
                     .css position:"absolute"
JUMLYPosition::_coordinate = (target)->
  if @attrs.coordinate
    @attrs.coordinate.append @div
  else
    target.after @div
    
class JUMLYPositionRightLeft extends JUMLYPosition
class JUMLYPositionLeftRight extends JUMLYPosition
class JUMLYPositionLeft      extends JUMLYPosition
class JUMLYPositionTop       extends JUMLYPosition

JUMLYPositionRightLeft::apply = ->
  src = @attrs.src
  @_coordinate src
  @div.offset left:src.offset().left + src.outerWidth()
  @attrs.dst.offset left:@div.offset().left + @div.outerWidth()

JUMLYPositionLeftRight::apply = ->
  src = @attrs.src
  dst = @attrs.dst
  @_coordinate src
  @div.offset left:src.offset().left - @div.outerWidth()
  @attrs.dst.offset left:@div.offset().left - @attrs.dst.outerWidth()

JUMLYPositionLeft::apply = ->
  dst = @attrs.dst
  @_coordinate dst
  @attrs.dst.offset left:(@div.offset().left + @div.outerWidth())

JUMLYPositionTop::apply = ->
  dst = @attrs.dst
  @_coordinate dst
  @attrs.dst.offset top:(@div.offset().top + @div.outerHeight())


JUMLYPosition.RightLeft = JUMLYPositionRightLeft
JUMLYPosition.LeftRight = JUMLYPositionLeftRight
JUMLYPosition.Left      = JUMLYPositionLeft
JUMLYPosition.Top       = JUMLYPositionTop

JUMLY.Position = JUMLYPosition
