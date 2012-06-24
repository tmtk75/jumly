class JUMLYPosition
  constructor: (@attrs)->
    @div = $("<div>").addClass @attrs.css
    
class JUMLYPositionRightLeft extends JUMLYPosition
class JUMLYPositionLeftRight extends JUMLYPosition
class JUMLYPositionLeft      extends JUMLYPosition

JUMLYPositionRightLeft::apply = ->
  src = @attrs.src
  src.after @div
  @attrs.dst.css left:src.offset().left + src.outerWidth() + @div.outerWidth() - src.offsetParent().offset().left

JUMLYPositionLeftRight::apply = ->
  src = @attrs.src
  dst = @attrs.dst
  src.after @div
  @attrs.dst.css left:src.offset().left - (@div.outerWidth() + dst.outerWidth()) - src.offsetParent().offset().left

JUMLYPositionLeft::apply = ->
  dst = @attrs.dst
  dst.before @div
  @attrs.dst.css left:(@div.outerWidth())

JUMLYPosition.RightLeft = JUMLYPositionRightLeft
JUMLYPosition.LeftRight = JUMLYPositionLeftRight
JUMLYPosition.Left      = JUMLYPositionLeft

JUMLY.Position = JUMLYPosition
