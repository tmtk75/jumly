self = require: JUMLY.require

class HorizontalSpacing
  constructor: (a, b)->
    $.extend this, $("<span>")
    @data("left", a)
    @data("right", b)
    @addClass "horizontal"
    @addClass "spacing"

HorizontalSpacing::apply = ->
  a = @data("left").data "_self"
  b = @data("right").data "_self"
  a.after this
  @offset left:a.offset().left + a.preferred_width(), top:a.offset().top
  b.offset left:@offset().left + @outerWidth()

root =
  HorizontalSpacing: HorizontalSpacing

core = self.require "core"
if core.env.is_node
  module.exports = root
else
  core.exports root, "HTMLElementLayout"
