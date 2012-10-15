core = require "core"

root =
  matchers: (suite)->
    suite.addMatchers
      haveClass: (expected)->
        @actual.hasClass expected
  
  div: (self)->
    HTMLElement = require "HTMLElement"
    klass = HTMLElement.to_css_name self.description
    div = $("<div>").attr("id", klass + "-container")
                    .addClass("spec-diagram-container")
    cont = $("body > #diagram-containers")
    if cont .length is 0
      cont = $("<div>").attr("id", "diagram-containers")
      $("body").append cont
    cont.append div
    div

  unless_node: (f)->
    f() unless core.env.is_node

if core.env.is_node
  module.exports = root
else
  core.exports root, "./jasmine-utils"
