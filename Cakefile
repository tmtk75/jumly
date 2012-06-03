util   = require "util"
fs     = require "fs"
path   = require "path"
muffin = require "muffin"
glob   = require "glob"
_      = require "underscore"

tmpdir = ".build" #(require "temp").mkdirSync()

task "compile", "compile *.coffee", (opts)->
  muffin.run
    files: ["./lib/jumly/js/*.coffee"]
    options: opts
    map:
      "([^/]+).coffee": (matches)->
        src = "./lib/jumly/js/#{matches[1]}.coffee"
        dst = "#{tmpdir}/#{matches[1]}.js"
        a = (fs.statSync src).mtime
        b = (fs.statSync dst).mtime if path.existsSync dst
        dirty = a > b or not(a and b)
        muffin.compileScript src, dst, bare:false if dirty

dstpath = "lib/jumly/build/jumly.js"

task "concat", "concatenate", (opts)->
  bodies = _.map (glob.sync "#{tmpdir}/*.js"), (e)-> (fs.readFileSync e).toString()
  muffin.writeFile dstpath, bodies.join ""

task "minify", "minify", ->
  muffin.run
    files: [dstpath]
    options: {}
    map:
      ".*": (matches)-> muffin.minifyScript matches[0]
    after: ->
      (fs.readFileSync "#{tmpdir}/jumly.min.js").toString()

#task "doc", "", (opts)-> muffin.doccoFile("./lib/jumly/js/core.coffee", opts)

