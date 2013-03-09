module.exports = (grunt)->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffee:
      compile:
        files:
          "build/<%= pkg.name %>.js": files.map (e)-> "lib/js/#{e}.coffee"

    stylus:
      compile:
        files:
          "build/<%= pkg.name %>.css": "lib/css/*.styl"

    uglify:
      options:
        banner: """/* <%= pkg.name %>-<%= pkg.version %> <%=grunt.template.today('yyyy-mm-dd')%> */\n"""
      build:
        src: 'build/<%= pkg.name %>.js'
        dest: 'build/<%= pkg.name %>.min.js'

    cssmin:
      compress:
        files:
          'build/<%= pkg.name %>.min.css': [ "build/<%= pkg.name %>.css" ]

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'

  grunt.registerTask 'default', ['uglify']

files = [
  "core", "jquery.g2d", "jquery.ext", "icon"
  "HTMLElement"
  "Diagram", "DiagramBuilder", "DiagramLayout"
  "HTMLElementLayout", "NoteElement", "Position", "Relationship",
  "SequenceLifeline", "SequenceMessage", "SequenceInteraction", "SequenceOccurrence", "SequenceParticipant"
  "SequenceDiagram", "SequenceDiagramBuilder", "SequenceDiagramLayout", "SequenceFragment", "SequenceRef", "UsecaseDiagram",
  #"Class", "ClassDiagram", "ClassDiagramBuilder"
]

