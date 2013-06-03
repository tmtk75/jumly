module.exports = (grunt)->

  pkg = grunt.file.readJSON('package.json')

  grunt.initConfig
    pkg: pkg

    coffee:
      compile:
        files:
          "build/<%= pkg.name %>.js": js_files.map (e)-> "lib/js/#{e}.coffee"
          "build/.spec/<%= pkg.name %>Spec.js": spec_files.map (e)-> "spec/#{e}.coffee"

      ###glob_to_multiple:
        expand: true
        cwd: 'spec'
        src: ['*.coffee']
        dest: 'build/.spec'
        ext: '.js' ###

    stylus:
      compile:
        files:
          "build/<%= pkg.name %>.css": "lib/css/jumly.styl"

    uglify:
      options:
        banner: """/* <%= pkg.name %>-<%= pkg.version %> <%=grunt.template.today('yyyy-mm-dd')%> */\n"""
        mangle: false  ## if true, jumly.min.js is corrupted
      build:
        src: 'build/<%= pkg.name %>.js'
        dest: 'build/<%= pkg.name %>.min.js'

    cssmin:
      compress:
        options:
          banner: """/* <%= pkg.name %>-<%= pkg.version %> <%=grunt.template.today('yyyy-mm-dd')%> */"""
        files:
          'build/<%= pkg.name %>.min.css': [ "build/<%= pkg.name %>.css" ]

    "jasmine-node":
      run:
        spec: 'spec',
      options:
        coffee: true,
      env:
        NODE_PATH: "lib/js"
      executable: './node_modules/.bin/jasmine-node'

    livereload:
      port: 35729

    regarde:
      css:
        files: 'lib/css/*.styl'
        tasks: ['stylus', 'cssmin']
      js:
        files: 'lib/js/*.coffee'
        tasks: ['coffee', 'uglify']
      coffee:
        files: ['spec/*.coffee']
        tasks: ['compile', 'jasmine-node']
      views:
        files: 'views/*.*'
        tasks: ['livereload']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-jasmine-node'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-regarde'
  grunt.loadNpmTasks 'grunt-contrib-livereload'

  grunt.registerTask 'default', ['build']
  grunt.registerTask 'minify', ['uglify', 'cssmin']
  grunt.registerTask 'compile', ['coffee', 'stylus']
  grunt.registerTask 'build', ['compile', 'minify']
  grunt.registerTask 'spec', ['jasmine-node']
  grunt.registerTask 'dev', ['livereload-start', 'regarde']
  grunt.registerTask 'release', "", ->
    grunt.task.requires ["build"]
    fs = require "fs"
    dir = "views/static/release"
    fs.mkdirSync dir unless fs.existsSync dir

    done = @async()
    require("child_process").exec "cp build/jumly.*  #{dir}; git add #{dir}", (err,stdout,stderr)->
      process.stdout.write stdout if stdout
      process.stderr.write stderr if stderr
      process.stderr.write err if err
      done(true)

fs = require "fs"
_  = require "underscore"
js_files = _.compact fs.readFileSync("lib/js/jumly.coffee").toString()
            .split("\n").map (e)-> e.replace("#= require ", "").trim()

spec_files = [
  "jasmine-utils"
  "coreSpec", "apiSpec", "issuesSpec"
  "DiagramSpec"
  "HTMLElementSpec"
  "SequenceDiagramBuilderSpec", "SequenceDiagramLayoutSpec", "SequenceDiagramSpec"
  "RobustnessDiagramBuilderSpec"
  #"ClassDiagramSpec"
]
