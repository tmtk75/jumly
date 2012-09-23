fs     = require "fs"
muffin = require "muffin"
glob   = require "glob"
_      = require "underscore"
exec   = require("child_process").exec

libdir = "lib"
jsdir  = "#{libdir}/js"
tmpdir = "build/.tmp"
basepath = "build/jumly"
dstpath  = "#{basepath}.js"
minpath  = "#{basepath}.min.js"
dstspecpath  = "#{basepath}Spec.js"
minspecpath  = "#{basepath}Spec.min.js"
version  = fs.readFileSync("#{libdir}/version").toString().trim() #replace /\n/, ""
header   = """
// JUMLY v#{version}, 2011-#{new Date().getFullYear()} copyright(c), all rights reserved.\n
"""

#option "-w", "--watch", "How do I specify argument?"

task "app", "run app", ->
  invoke "watch"
  exec "./app.coffee", (err,stdout,stderr)->
    console.log err, stdout, stderr

task "watch", "watch all", ->
  invoke "css"

task "build", "build", ->
  invoke "compile"
  invoke "compile::spec"
  invoke "concat"
  invoke "concat::spec"

task "css", "compile *.styl and watch them", ->
  exec "stylus -w views -o views/static", (err,stdout,stderr)->
    console.log err, stdout, stderr

compile = (srcdir, dstdir)->
  (matches)->
    src = "#{srcdir}/#{matches[1]}.coffee"
    dst = "#{dstdir}/#{matches[1]}.js"
    a = (fs.statSync src).mtime
    b = (fs.statSync dst).mtime if fs.existsSync dst
    muffin.compileScript src, dst, bare:false if a >= b or not(a and b)

task "compile", "compile *.coffee", ->
  muffin.run
    files: ["#{jsdir}/*.coffee"]
    options: {}
    map:
      "([^/]+).coffee": compile "lib/js", tmpdir

task "compile::spec", "compile *.coffee", ->
  muffin.run
    files: ["spec/*.coffee"]
    options: {}
    map:
      "([^/]+).coffee": compile "spec", tmpdir
      

files = ["core", "HTMLElement"]
files = files.map (e)-> "#{tmpdir}/#{e}.js"

task "concat", "concatenate", ->
  bodies = _.map files, (e)-> (fs.readFileSync e).toString()
  muffin.writeFile dstpath, [header].concat(bodies).join ""

task "concat::spec", "concatenate spec", ->
  bodies = _.map (glob.sync "#{tmpdir}/*Spec.js"), (e)-> (fs.readFileSync e).toString()
  muffin.writeFile dstspecpath, [header].concat(bodies).join ""

task "minify", "minify", ->
  muffin.run
    files: [dstpath]
    options: {}
    map:
      "lib/*.js": (matches)-> muffin.minifyScript matches[0]
    after: ->
      body = (fs.readFileSync dstpath).toString()
      muffin.writeFile minpath, header + body

task "minify::spec", "minify", ->
  muffin.run
    files: [dstspecpath]
    options: {}
    map:
      "lib/*.js": (matches)-> muffin.minifyScript matches[0]
    after: ->
      body = (fs.readFileSync dstspecpath).toString()
      muffin.writeFile minspecpath, header + body

task "spec", "", ->
  exec "NODE_PATH=lib/js jasmine-node --coffee spec", (err,stdout,stderr)->
    console.log err, stdout, stderr
  

cmd = "jasmine-node --coffee #{libdir}/js"
task "spec::struct", "print command line to run spec::struct", ->
  console.log "#{cmd}/spec/struct"

task "spec::position", "print command line to run spec::position", ->
  console.log "#{cmd}/spec/position"

task "spec::legacy", "print command line to run legacy spec::legacy", ->
  console.log "#{cmd}/legacy"
