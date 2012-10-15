HTMLElement = require "HTMLElement"
class SequenceLifeline extends HTMLElement

SequenceLifeline::_build_ = (div, props)->
  div.append($("<div>").addClass("line").height(128))
	   .width(props[".object"].width())
	   .height(128)

core = require "core"
if core.env.is_node
  module.exports = SequenceLifeline
else
  core.exports SequenceLifeline
