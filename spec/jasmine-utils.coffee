#core = require "core.coffee"
#HTMLElement = require "HTMLElement"
#L = require "SequenceDiagramLayout"

root =
  matchers: (suite)->
    jasmine.addMatchers
      haveClass: (util, customEqualityTesters)->
        compare: (actual, expected)->
          b = actual.hasClass expected
          pass: b, message: b ? "have" : "doesn't have"
  
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

module.exports = root
