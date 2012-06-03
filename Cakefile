util = require "util"
muffin = require "muffin"

compile = (options)->
  muffin.run
    files: ["./lib/jumly/js/*.coffee"]
    options: {} #options
    map:
      "([^/]+).coffee": (matches) ->
        basename = matches[1]
        muffin.compileScript "./lib/jumly/js/#{basename}.coffee", "build/#{basename}.js", options

task "compile", "", compile
