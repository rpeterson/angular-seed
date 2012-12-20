module.exports = (grunt) ->
  grunt.loadNpmTasks "grunt-recess"
  grunt.loadNpmTasks "grunt-coffee"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadTasks "build"

  # Project configuration.
  grunt.initConfig
    distdir: "dist"
    pkg: "<json:package.json>"
    meta:
      banner: "/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - " + "<%= grunt.template.today(\"yyyy-mm-dd\") %>\n" + "<%= pkg.homepage ? \"* \" + pkg.homepage + \"\n\" : \"\" %>" + "* Copyright (c) <%= grunt.template.today(\"yyyy\") %> <%= pkg.author %>;\n" + " Licensed <%= _.pluck(pkg.licenses, \"type\").join(\", \") %> */"

    src:
      js: ["vendor/*.js","vendor/build/build.js","src/**/*.js", "dist/tmp/**/*.js"]
      coffee: ["src/**/*.coffee"]
      html: ["src/index.html"]
      tpl: ["src/app/**/*.tpl.html"]
      less: ["src/less/stylesheet.less"] # recess:build doesn't accept ** in its file patterns

    clean: ["<%= distdir %>/*"]
    copy:
      assets:
        files:
          "<%= distdir %>/": "src/assets/**"
      vendor:
        files:
          "<%= distdir %>/build/": "vendor/build/**"

    test:
      unit: ["test/unit/**/*Spec.coffee"]
      e2e: ["test/e2e/**/*Scenario.coffee"]

    coffee:
      dist:
        src: ["src/**/*.coffee"]
        dest: "src/build/"

    html2js:
      src: ["<config:src.tpl>"]
      base: "src/app"
      dest: "dist/tmp"

    concat:
      dist:
        src: ["<banner:meta.banner>", "<config:src.js>"]
        dest: "<%= distdir %>/<%= pkg.name %>.js"

#      angular:
#        src: ["vendor/build/build.js"]
#        dest: "<%= distdir %>/angular.js"

    min:
      dist:
        src: ["<banner:meta.banner>", "<config:src.js>"]
        dest: "<%= distdir %>/<%= pkg.name %>.js"

      angular:
        src: ["<config:concat.angular.src>"]
        dest: "<%= distdir %>/angular.js"

    recess:
      build:
        src: ["<config:src.less>"]
        dest: "<%= distdir %>/<%= pkg.name %>.css"
        options:
          compile: true

      min:
        src: ["<config:src.less>"]
        dest: "<config:recess.build.dest>"
        options:
          compress: true

    watch:
      files: ["<config:src.js>", "<config:test.unit>", "<config:src.less>", "<config:src.tpl>", "<config:src.html>", "<config:src.coffee>"]
      tasks: "default timestamp"

    jshint:
      options:
        curly: true
        eqeqeq: true
        immed: true
        latedef: true
        newcap: true
        noarg: true
        sub: true
        boss: true
        eqnull: true

      globals: {}

    uglify: {}


  # Default task.
  grunt.registerTask "default", "build watch"# test:unit"
  grunt.registerTask "build", "clean coffee html2js concat recess:build index copy"
  grunt.registerTask "release", "clean html2js min coffee test recess:min index copy e2e"

  # HTML stuff
  grunt.registerTask "index", "Process index.html", ->
    grunt.file.copy "src/index.html", "dist/index.html",
      process: grunt.template.process



  # Print a timestamp (useful for when watching)
  grunt.registerTask "timestamp", ->
    grunt.log.subhead Date()
