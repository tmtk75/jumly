_       = require "underscore"
fs      = require "fs"
brownie = require "brownie"

version  = brownie.read("lib/version").trim() #replace /\n/, ""
copyright = """
// JUMLY v#{version}, 2011-#{new Date().getFullYear()} copyright(c), all rights reserved.\n
"""

brownie.configure
  basename: "build/jumly"

task "build", "", ->
  invoke e for e in ["compile", "css:compile"]

task "compile", "compile *.coffee", ->
  brownie.compile order:order()

task "release", "", ->
  js = "build/jumly.js"
  css = "build/jumly.css"
  unless fs.existsSync js
    console.warn "#{js} is missing. run `cake build`"
    return
  unless fs.existsSync css
    console.warn "#{css} is missing. run `cake build`"
    return
  verdir = "views/static/release/#{version}"
  brownie.exec """
    rm -rf #{verdir}
    mkdir -p #{verdir}
    cp build/jumly.js #{verdir}/jumly.js
    cp build/jumly.css #{verdir}/jumly.css
    git add #{verdir}/jumly.js
    git add #{verdir}/jumly.css
    """
  console.log "release #{verdir}"

task "minify", "minify jumly.js and jumly.css", ->
  brownie.minify minified_files:["build/jumly.js"], header:copyright
  brownie.exec """
    mkdir -p build/.css
    stylus -c lib/css/jumly.styl -o build/.css
    cp build/.css/jumly.css build/jumly.min.css
    """

task "clean", "clean", ->
  brownie.exec """
    rm -rf build lib/css/*.css
    """

namespace "css", ->
  
  task "compile", "compile lib/css/*.styl", ->
    brownie.exec """
      mkdir -p build/.css
      stylus lib/css -o build/.css
      cp build/.css/jumly.css build
      """
  task "watch", "compile lib/css/*.styl and watch them", ->
    brownie.exec "stylus -w lib/css -o lib/css"

namespace "spec", ->

  task "compile", "compile *.coffee", ->
    brownie.compile srcdir:"spec", tmpdir:"build/.spec", suffix:"Spec"

  task "run", "run spec with jasmine-node", ->
    brownie.jasmine "spec"

task "app:run", "run app", ->
  brownie.exec "./app.coffee"
  brownie.exec "touch lib/js/jumly.coffee"

order = ->
  [].concat core, common, diagram, sequence

core = ["core", "jquery.g2d", "jquery.ext"]
common = ["HTMLElement"]
diagram = ["Diagram", "DiagramBuilder", "DiagramLayout"]
sequence = ["SequenceLifeline", "SequenceMessage", "SequenceInteraction", "SequenceOccurrence", "SequenceObject"]
