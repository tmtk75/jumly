class JUMLYPosition
  constructor: (@attrs)->
    @div = $("<div>").addClass @attrs.css
    
class JUMLYPositionRightLeft extends JUMLYPosition

JUMLYPositionRightLeft::apply = ->
  src = @attrs.src
  src.offsetParent().append @div
  @attrs.dst.css left:src.position().left + src.outerWidth() + @div.outerWidth()

JUMLYPosition.RightLeft = JUMLYPositionRightLeft

JUMLY.Position = JUMLYPosition
