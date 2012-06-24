class JUMLYPosition
  constructor: (@attrs)->
    @div = $("<div>").addClass @attrs.css
    
class JUMLYPositionRightLeft extends JUMLYPosition
class JUMLYPositionLeftRight extends JUMLYPosition

JUMLYPositionRightLeft::apply = ->
  src = @attrs.src
  src.offsetParent().after @div
  @attrs.dst.css left:src.position().left + src.outerWidth() + @div.outerWidth()

JUMLYPositionLeftRight::apply = ->
  src = @attrs.src
  dst = @attrs.dst
  src.offsetParent().after @div
  @attrs.dst.css left:src.position().left - (@div.outerWidth() + dst.outerWidth())

JUMLYPosition.RightLeft = JUMLYPositionRightLeft
JUMLYPosition.LeftRight = JUMLYPositionLeftRight

JUMLY.Position = JUMLYPosition
