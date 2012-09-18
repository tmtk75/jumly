JUMLY = window.JUMLY
class JUMLYObject extends JUMLY.HTMLElement

JUMLYObject::_build_ = (div)->
  div.addClass("object")
     .append($("<div>").addClass("name"))

JUMLYObject::activate = ->
  _as = $.jumly.lang._as
  occurr = $.jumly(type:".occurrence", ".object":this)
  iact = $.jumly(type:".interaction", ".occurrence":_as(".actor":null, ".actee":occurr), ".actor":null, ".actee":occurr)
  iact.addClass "activated"
  iact.find(".message").remove()
  iact.append(occurr)
  @parent().append(iact)
  occurr

JUMLYObject::isLeftAt = (a)-> @offset().left < a.offset().left

JUMLYObject::isRightAt = (a)-> (a.offset().left + a.width()) < @offset().left

JUMLYObject::iconify = (fixture, styles)->
  unless typeof fixture is "function"
    fixture = $.jumly.icon["." + fixture] || $.jumly.icon[".actor"]
  canvas = $("<canvas>").addClass("icon")
  container = $("<div>").addClass("icon-container")
  @addClass("iconified").prepend(container.append canvas)

  {size, styles} = fixture canvas[0], styles
  container.css height:size.height #, width:size.width ##FIXME: Way to decide the width.
  render = =>
    name = @find(".name")
    styles.fillStyle   = name.css("background-color")
    styles.strokeStyle = name.css("border-top-color")
    fixture canvas[0], styles
  this.renderIcon = -> render()
  this

JUMLYObject::lost =-> @activate().interact(null, {stereotype:".lost"})

JUMLY.def ".object", JUMLYObject


