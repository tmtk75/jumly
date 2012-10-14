DiagramLayout = require "DiagramLayout"

class SequenceDiagramLayout extends DiagramLayout

SequenceDiagramLayout::_layout_ = ->
  @align_objects_horizontally()
  @align_occurrences_horizontally()
  @compose_interactions()
  @generate_lifelines_and_align_horizontally()
  @pack_object_lane_vertically()
  @pack_refs_horizontally()
  @pack_fragments_horizontally()
  @align_creation_message_horizontally()
  @align_lifelines_vertically()
  @align_lifelines_stop_horizontally()
  @rebuild_asynchronous_self_calling()
  @render_icons()
  @diagram.width @diagram.preferredWidth()
  
SequenceDiagramLayout::align_objects_horizontally = ->
  f0 = (a)=>
    if a.css("left") is "auto"
      a.css left:@prefs.compose_most_left
  f1 = (a, b)=>
    if b.css("left") is "auto"
      spacing = new JUMLY.HorizontalSpacing(a, b)
      spacing.apply()
  @_q(".object").pickup2 f0, f1

SequenceDiagramLayout::align_occurrences_horizontally = ->
   @_q(".occurrence").selfEach (e)-> e.moveHorizontally()

SequenceDiagramLayout::compose_interactions = ->
  @_q(".occurrence .interaction").selfEach (e)-> e._compose_()

jumly = $.jumly

SequenceDiagramLayout::generate_lifelines_and_align_horizontally = ->
  @_q(".lifeline").remove()
  @_q(".object").selfEach (obj)->
    a = jumly type:".lifeline", ".object":obj
    a.offset left:obj.offset().left, top:obj.outerBottom() + 1
    a.insertAfter obj

SequenceDiagramLayout::pack_object_lane_vertically = ()->
  objs = @_q(".object")
  mostheight = jQuery.max objs, (e) -> $(e).outerHeight()
  mostheight ?= 0
  $(".object-lane").height(mostheight).swallow(objs)

SequenceDiagramLayout::pack_refs_horizontally = ->
  refs = @_q(".ref")
  return if refs.length is 0
  $(refs).selfEach (ref) ->
    pw = ref.preferredWidth()
    ref.offset(left:pw.left)
       .width(pw.width)

SequenceDiagramLayout::pack_fragments_horizontally = ->
  # fragments just under this diagram.
  fragments = $ "> .fragment", @diagram
  if fragments.length > 0
    # To controll the width, you can write selector below.
    # ".object:eq(0), > .interaction > .occurrence .interaction"
    most = @_q(".object").mostLeftRight()
    left = fragments.offset().left
    fragments.width (most.right - left) + (most.left - left)
  
  # fragments inside diagram
  fixwidth = (fragment) ->
    most = $(".occurrence, .message, .fragment", fragment).not(".return, .lost").mostLeftRight()
    fragment.width(most.width() - (fragment.outerWidth() - fragment.width()))
    ## WORKAROUND: it's tentative for both of next condition and the body
    msg = jumly(fragment.find("> .interaction > .message"))[0]
    if (msg?.isTowardLeft())
      fragment.offset(left:most.left)
              .find("> .interaction > .occurrence")
              .each (i, occurr) ->
                occurr = jumly(occurr)[0]
                occurr.moveHorizontally()
                      .prev().offset left:occurr.offset().left
  
  @_q(".occurrence > .fragment")
    .selfEach(fixwidth)
    .parents(".occurrence > .fragment")
    .selfEach(fixwidth)

SequenceDiagramLayout::align_lifelines_vertically = ->
  mostbottom = @diagram.find(".occurrence")
                       .not(".interaction.lost .occurrence")
                       .max (e) -> $(e).outerBottom()
  @_q(".lifeline").selfEach (a) ->
    obj = a.gives(".object")
    y = obj.outerBottom() + 1
    a.offset left:obj.offset().left, top:y
    h = mostbottom - y + 16
    a.height h
    a.find(".line").css(top:0).height h

SequenceDiagramLayout::align_lifelines_stop_horizontally = ->
  $(".stop", @diagram).each (i, e) ->
    e = $(e)
    occurr = e.prev(".occurrence")
    e.offset left:occurr.offset().left

SequenceDiagramLayout::align_creation_message_horizontally = ->
  @_q(".message.create").selfEach (e)->
    e._composeLooksOfCreation()

SequenceDiagramLayout::rebuild_asynchronous_self_calling = ->
  @diagram.find(".message.asynchronous").parents(".interaction:eq(0)").each (i, e) ->
    e = $(e).self()
    if not e.isToSelf()
        return
    iact = e.addClass("activated")
            .addClass("asynchronous")
    prev = iact.parents(".interaction:eq(0)")
    iact.insertAfter prev
    
    occurr = iact.css("padding-bottom", 0)
                 .find("> .occurrence").self()
                 .moveHorizontally()
                 .css("top", 0)

    msg = iact.find(".message").self()
    msg.css("z-index", -1)
       .offset
         left: occurr.offset().left
         top : prev.find(".occurrence").outerBottom() - msg.height()/3

SequenceDiagramLayout::render_icons = ->
  @_q(".object").selfEach (e)-> e.renderIcon?()

core = require "core"
if core.env.is_node
  module.exports = SequenceDiagramLayout
else
  core.exports SequenceDiagramLayout
