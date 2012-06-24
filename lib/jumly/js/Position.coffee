class JUMLYPosition
  constructor: (@attrs)->
    
class JUMLYPositionRightLeft extends JUMLYPosition
JUMLYPositionRightLeft::apply = ->
  a = @attrs.src.position().left
  b = @attrs.src.outerWidth()
  @attrs.dst.css left:a + b

JUMLYPosition.RightLeft = JUMLYPositionRightLeft

JUMLY.Position = JUMLYPosition
