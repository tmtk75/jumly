util   = require "util"
fs     = require "fs"
path   = require "path"
muffin = require "muffin"
glob   = require "glob"
_      = require "underscore"

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
        dirty = a > b or not(a and b)
        muffin.compileScript src, dst, bare:false if dirty

concat = (opts)->
  bodies = _.map (glob.sync "build/*"), (e)-> (fs.readFileSync e).toString()
  muffin.writeFile "build/jumly.js", bodies.join ""

minify = (opts)-> muffin.minifyScript "build/jumly.js"

task "compile", "compile *.coffee in ./build", compile
task "concat",  "concatenate ./build/*.js", concat
task "minify",  "minify ./build/jumly.js", minify
task "doc", "", (opts)-> #muffin.doccoFile("./lib/jumly/js/core.coffee", opts)

