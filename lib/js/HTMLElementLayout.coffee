class HorizontalSpacing
  constructor: (a, b)->
    $.extend this, $("<span>")
    @data("a", a)
    @data("b", b)
    @addClass "horizontal"
    @addClass "spacing"

HorizontalSpacing::apply = ->
  a = @data("a")
  b = @data("b")
  a.after this
  @offset left:a.offset().left + a.outerWidth(), top:a.offset().top
  b.offset left:@offset().left + @outerWidth() + 1

root =
  HorizontalSpacing: HorizontalSpacing

core = require "core"
if core.env.is_node
  module.exports = root
else
  (require "core").exports root, "HTMLElementLayout"
