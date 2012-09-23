_       = require("underscore")
brownie = require("brownie")

version  = brownie.read("lib/version").trim() #replace /\n/, ""
copyright = """
// JUMLY v#{version}, 2011-#{new Date().getFullYear()} copyright(c), all rights reserved.\n
"""

brownie.configure
  basename: "build/jumly"

task "compile", "compile *.coffee", ->
  _f = (them)->
    prior = ["core", "jquery.g2d", "jquery.ext"]
    them = them.filter (e)-> not _.include prior, require("path").basename(e, ".js")
    _.union prior.map((e)->"build/.js/#{e}.js"), them

  brownie.compile sort:_f

task "minify", "minify jumly.js", ->
  brownie.minify header:copyright

namespace "spec", ->

  task "run", "run spec with jasmine-node", ->
    brownie.jasmine "spec"

  task "compile", "compile *.coffee", ->
    brownie.compile srcdir:"spec", tmpdir:"build/.spec", suffix:"Sepc"

task "app::run", "run app", ->
  brownie.exec "./app.coffee"

task "css::watch", "compile *.styl and watch them", ->
  brownie.exec "stylus -w views -o views/static"

