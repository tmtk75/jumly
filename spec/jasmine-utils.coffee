root =
  matchers: (suite)->
    suite.addMatchers
      haveClass: (expected)->
        @actual.hasClass expected
  
  div: (self)->
    HTMLElement = require "HTMLElement"
    klass = HTMLElement.to_css_name self.description
    div = $("<div>").attr("id", klass + "-container").addClass("spec")
    $("body").append div
    div

core = require "core"
if core.env.is_node
  module.exports = root
else
  core.exports root, "./jasmine-utils"
