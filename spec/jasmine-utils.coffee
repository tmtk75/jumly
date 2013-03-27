self = require: unless typeof require is "undefined" then require else JUMLY.require
core = self.require "core"
HTMLElement = self.require "HTMLElement"
L = self.require "SequenceDiagramLayout"

root =
  matchers: (suite)->
    suite.addMatchers
      haveClass: (expected)->
        @actual.hasClass expected
  
  div: (self)->
    klass = HTMLElement.to_css_name self.description
    div = $("<div>").attr("id", klass + "-container")
                    .addClass("spec-diagram-container")
                    .prepend($("<div>").addClass("description").text self.description)
    cont = $("body > #diagram-containers")
    if cont .length is 0
      cont = $("<div>").attr("id", "diagram-containers")
      $("body").append cont
    cont.append div
    div

  unless_node: (f)->
    f() unless core.env.is_node

  glance: (diag)->
    $("body").prepend diag
    new L().layout diag

  ua: (opts)->
    for e of opts
      return opts[e] if $("html").hasClass "ua-#{e}"
    opts["webkit"]

if core.env.is_node
  module.exports = root
else
  core.exports root, "./jasmine-utils"
