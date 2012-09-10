class JUMLYHorizontalSpacing
  constructor: (a, b)->
    $.extend this, $("<span>")
    @data("a", a)
    @data("b", b)
    @addClass "horizontal"
    @addClass "spacing"

JUMLYHorizontalSpacing::apply = ->
  a = @data("a")
  b = @data("b")
  a.after this
  @offset left:a.offset().left + a.outerWidth(), top:a.offset().top
  b.offset left:@offset().left + @outerWidth() + 1

JUMLY.HorizontalSpacing = JUMLYHorizontalSpacing

