_       = require("underscore")
muffin  = require("muffin")
brownie = require("brownie")

jssrcdir = "lib/js"
jstmpdir = "build/.js"
specdir = "build/.spec"
basepath = "build/jumly"
dstpath  = "#{basepath}.js"
minpath  = "#{basepath}.min.js"
dstspecpath  = "#{basepath}Spec.js"
version  = brownie.read("lib/version").trim() #replace /\n/, ""
copyright = """
// JUMLY v#{version}, 2011-#{new Date().getFullYear()} copyright(c), all rights reserved.\n
"""

task "compile", "compile *.coffee", ->
  _f = (them)->
    prior = ["core", "jquery.g2d", "jquery.ext", "support"]
    them = them.filter (e)-> not _.include prior, require("path").basename(e, ".js")
    _.union prior.map((e)->"build/.js/#{e}.js"), them

  brownie.compile srcdir:jssrcdir, dstdir:jstmpdir, dstpath:dstpath, sort:_f

task "minify", "minify jumly.js", ->
  brownie.minify srcpath:dstpath, dstpath:minpath, header:copyright

task "spec::run", "run spec with jasmine-node", ->
  brownie.exec "NODE_PATH=lib/js jasmine-node --coffee spec"

task "spec::compile", "compile *.coffee", ->
  brownie.compile srcdir:"spec", dstdir:specdir, dstpath:dstspecpath

task "app::run", "run app", ->
  brownie.exec "./app.coffee"

task "css::watch", "compile *.styl and watch them", ->
  brownie.exec "stylus -w views -o views/static"

