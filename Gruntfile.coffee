module.exports = (grunt)->

  pkg = grunt.file.readJSON('package.json')

  grunt.initConfig
    pkg: pkg

    uglify:
      options:
        ## About format, see http://blog.stevenlevithan.com/archives/date-time-format
        banner: """/* <%= pkg.name %>-<%= pkg.version %> <%=grunt.template.today('UTC:yyyy-mm-dd"T"HH:MM:ss"Z"')%> */\n"""
        mangle: false  ## if true, jumly.min.js is corrupted
      build:
        src: 'dist/bundle.lib.js'
        dest: 'public/<%= pkg.name %>.min.js'

  grunt.loadNpmTasks 'grunt-contrib-uglify'

  grunt.registerTask 'default', ['minify']
  grunt.registerTask 'minify',  ['uglify']
