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

minify = (opts)->
  q = require "q"
  _q = muffin.minifyScript "build/jumly.js"
  _q.then ->
    body = fs.readFileSync "build/jumly.min.js"
    _q = muffin.writeFile "build/jumly.min.js", "//alskdjf\n" + body.toString()
    console.log _q

task "compile", "compile *.coffee in ./build", compile
task "concat",  "concatenate ./build/*.js", concat
task "minify",  "minify ./build/jumly.js", (opts)->
  invoke "concat" if path.existsSync "build/jumly.js"
  minify opts
#task "doc", "", (opts)-> muffin.doccoFile("./lib/jumly/js/core.coffee", opts)

