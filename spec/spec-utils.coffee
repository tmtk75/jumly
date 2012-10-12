core = require "core"
HTMLElement = require "HTMLElement"

root =
  setup: (self)->
    klass = HTMLElement.to_css_name self.description
    div = $("<div>").addClass(klass).addClass("spec")
    $("body").append div
    div

if core.env.is_node
  module.exports = root
else
  core.exports root, "./spec-utils"
