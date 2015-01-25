$ = require "jquery"
core = require "core.coffee"
HTMLElement = require "HTMLElement.coffee"
L = require "SequenceDiagramLayout.coffee"

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
    #indow.document.write "hello"
    if cont.length is 0
      cont = $("<div>").attr("id", "diagram-containers")
      $("body").append cont
    cont.append div
    div

  glance: (diag)->
    $("body").prepend diag
    new L().layout diag

  ua: (opts)->
    for e of opts
      return opts[e] if $("html").hasClass "ua-#{e}"
    opts["webkit"]

  bottom: (e)-> Math.round e.offset().top + e.outerHeight() - 1

  top: (e)-> Math.round e.offset().top

  right: (e)-> Math.round e.offset().left + e.outerWidth() - 1

  left: (e)-> Math.round e.offset().left

module.exports = root
