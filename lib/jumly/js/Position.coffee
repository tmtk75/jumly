class JUMLYPosition
  constructor: (@attrs)->
    @div = $("<div>").addClass @attrs.css
    
class JUMLYPositionRightLeft extends JUMLYPosition
class JUMLYPositionLeftRight extends JUMLYPosition
class JUMLYPositionLeft      extends JUMLYPosition

JUMLYPositionRightLeft::apply = ->
  src = @attrs.src
  src.after @div
  @div.offset left:src.offset().left + src.outerWidth()
  @attrs.dst.offset left:@div.offset().left + @div.outerWidth()

JUMLYPositionLeftRight::apply = ->
  src = @attrs.src
  dst = @attrs.dst
  src.after @div
  @div.offset left:src.offset().left - @div.outerWidth()
  @attrs.dst.offset left:@div.offset().left - @attrs.dst.outerWidth()

JUMLYPositionLeft::apply = ->
  dst = @attrs.dst
  dst.before @div
  @attrs.dst.css left:(@div.outerWidth())

JUMLYPosition.RightLeft = JUMLYPositionRightLeft
JUMLYPosition.LeftRight = JUMLYPositionLeftRight
JUMLYPosition.Left      = JUMLYPositionLeft

JUMLY.Position = JUMLYPosition
