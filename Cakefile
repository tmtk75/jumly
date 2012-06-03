util = require "util"
muffin = require "muffin"

compile = (opts)->
  muffin.run
    files: ["./lib/jumly/js/*.coffee"]
    options: opts
    map:
      "([^/]+).coffee": (matches) ->
        tmpdir = "build" #(require "temp").mkdirSync()
        muffin.compileScript "./lib/jumly/js/#{matches[1]}.coffee", "#{tmpdir}/#{matches[1]}.js", opts

concat = (opts)->
  muffin.run
    files: ["./build/*.js"]
    options: opts
    map:
      ""

task "compile", "", compile
task "concat", "", (opts)->
  invoke "compile"
  concat opts
