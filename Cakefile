_       = require("underscore")
brownie = require("brownie")

version  = brownie.read("lib/version").trim() #replace /\n/, ""
copyright = """
// JUMLY v#{version}, 2011-#{new Date().getFullYear()} copyright(c), all rights reserved.\n
"""

brownie.configure
  basename: "build/jumly"

task "compile", "compile *.coffee", ->
  brownie.exec "touch lib/js/jumly.coffee"
  brownie.compile order:order()

task "minify", "minify jumly.js", ->
  brownie.minify header:copyright

namespace "spec", ->

  task "run", "run spec with jasmine-node", ->
    brownie.jasmine "spec"

  task "compile", "compile *.coffee", ->
    brownie.compile srcdir:"spec", tmpdir:"build/.spec", suffix:"Spec"

task "app:run", "run app", ->
  brownie.exec "./app.coffee"

task "css:watch", "compile *.styl and watch them", ->
  brownie.exec "stylus -w lib/css -o lib/css"

order = ->
  [].concat core, common, diagram, sequence

core = ["core", "jquery.g2d", "jquery.ext"]
common = ["HTMLElement"]
diagram = ["Diagram", "DiagramBuilder", "DiagramLayout"]
sequence = ["SequenceInteraction", "SequenceOccurrence", "SequenceObject"]
