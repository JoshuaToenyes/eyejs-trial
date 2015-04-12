module.exports = (grunt) ->

  config =

    pkg: (grunt.file.readJSON('package.json'))


    coffeelint:
      options:
        configFile: 'coffeelint.json'
      app: ['src/**/*.coffee']


    coffee:
      server:
        expand: true
        flatten: false
        cwd: 'src/coffee/server'
        src: ['*.coffee']
        dest: 'www'
        ext: '.js'
      client:
        expand: true
        flatten: false
        cwd: 'src/coffee/client'
        src: ['*.coffee']
        dest: 'tmp'
        ext: '.js'


    browserify:
      client:
        files:
          'www/js/scripts.js': ['tmp/**/*.js']

    sass:
      client:
        options:
          loadPath: 'lib/'
        files:
          'www/css/styles.css': 'src/sass/styles.sass'


    watch:
      all:
        files: ['src/**/*.coffee', 'src/**/*.sass'],
        tasks: ['compile']
        configFiles:
          files: ['Gruntfile.coffee']
          options:
            reload: true
      clientjs:
        files: ['src/coffee/client/*.coffee'],
        tasks: ['compile:client:js']
        configFiles:
          files: ['Gruntfile.coffee']
          options:
            reload: true
      clientcss:
        files: ['src/**/*.sass'],
        tasks: ['compile:client:css']
        configFiles:
          files: ['Gruntfile.coffee']
          options:
            reload: true

    clean:
      www: ['www/*.js']
      client: ['www/js/*.js', 'www/css/*.css']



  grunt.initConfig(config)

  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-sass')
  grunt.loadNpmTasks('grunt-browserify')

  grunt.registerTask 'compile', [
    'coffeelint'
    'clean'
    'coffee'
    'browserify'
    'sass'
  ]

  grunt.registerTask 'compile:client:js', [
    'coffeelint'
    'coffee:client'
    'browserify'
  ]

  grunt.registerTask 'compile:client:css', [
    'sass'
  ]
