util   = require "util"
fs     = require "fs"
path   = require "path"
muffin = require "muffin"
glob   = require "glob"

compile = (opts)->
  muffin.run
    files: ["./lib/jumly/js/*.coffee"]
    options: opts
    map:
      "([^/]+).coffee": (matches)->
        tmpdir = "build" #(require "temp").mkdirSync()
        src = "./lib/jumly/js/#{matches[1]}.coffee"
        dst = "#{tmpdir}/#{matches[1]}.js"
        a = (fs.statSync src).mtime
        b = (fs.statSync dst).mtime if path.existsSync dst
        dirty = a > b
        muffin.compileScript src, dst, bare:false if dirty

concat = (opts)->

task "compile", "", compile
task "concat", "", (opts)->
  concat opts
