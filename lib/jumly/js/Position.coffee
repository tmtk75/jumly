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

  dx = @div.offsetParent().offset().left - @attrs.dst.offsetParent().offset().left

  @attrs.dst.offset left:@div.offset().left + @div.outerWidth()

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
