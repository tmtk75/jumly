class JUMLYPosition
  constructor: (@attrs)->
    @div = $("<div>").addClass @attrs.css
    
class JUMLYPositionRightLeft extends JUMLYPosition
class JUMLYPositionLeftRight extends JUMLYPosition
class JUMLYPositionLeft      extends JUMLYPosition

JUMLYPositionRightLeft::apply = ->
  src = @attrs.src
  src.offsetParent().after @div
  @attrs.dst.css left:src.position().left + src.outerWidth() + @div.outerWidth()

JUMLYPositionLeftRight::apply = ->
  src = @attrs.src
  dst = @attrs.dst
  src.offsetParent().after @div
  @attrs.dst.css left:src.position().left - (@div.outerWidth() + dst.outerWidth())

JUMLYPositionLeft::apply = ->
  dst = @attrs.dst
  dst.offsetParent().after @div
  @attrs.dst.css left:(@div.outerWidth())

JUMLYPosition.RightLeft = JUMLYPositionRightLeft
JUMLYPosition.LeftRight = JUMLYPositionLeftRight
JUMLYPosition.Left      = JUMLYPositionLeft

JUMLY.Position = JUMLYPosition
