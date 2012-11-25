_       = require "underscore"
fs      = require "fs"
brownie = require "brownie"

version  = brownie.read("lib/version").trim()
copyright = """
JUMLY v#{version.split("\n").join("-")}, 2011-#{new Date().getFullYear()} copyright(c), all rights reserved Tomotaka Sakuma. build #{new Date().toGMTString()}
"""

brownie.configure
  basename: "build/jumly"

task "build", "", ->
  invoke e for e in ["compile", "css:compile"]

task "compile", "compile *.coffee", ->
  brownie.compile order:order()

task "release", "", ->
  js     = "build/jumly.js"
  css    = "build/jumly.css"
  minjs  = "build/jumly.min.js"
  mincss = "build/jumly.min.css"
  for e in [js, css, minjs, mincss]
    unless fs.existsSync e
      console.warn "#{e} is missing. run `cake build` and `cake minify`"
      return
  verpath = version.split("\n")[0]
  verdir = "views/static/release/#{verpath}"
  brownie.exec """
    rm -rf #{verdir}
    mkdir -p #{verdir}
    echo "//#{copyright}"     > #{verdir}/jumly.js
    echo "/* #{copyright} */" > #{verdir}/jumly.css
    cat build/jumly.js        >> #{verdir}/jumly.js
    cat build/jumly.css       >> #{verdir}/jumly.css
    cp build/jumly.min.js #{verdir}
    cp build/jumly.min.css #{verdir}
    git add #{verdir}/jumly.js #{verdir}/jumly.css #{verdir}/jumly.min.js #{verdir}/jumly.min.css
    git add lib/version
    """
  console.log "release #{verdir}"

task "minify", "minify jumly.js and jumly.css", ->
  js = "build/jumly.js"
  unless fs.existsSync js
    console.warn "#{js} is missing. run `cake build`"
    return
  brownie.minify minified_files:[js], header:"//#{copyright}\n"
  brownie.exec """
    mkdir -p build/.css
    stylus -c lib/css/jumly.styl -o build/.css
    printf "/* #{copyright} */" > build/jumly.min.css
    cat build/.css/jumly.css >> build/jumly.min.css
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
