module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # BDD tests on Node.js
    mochaTest:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'
          timeout: 10000
          require: 'coffee-script/register'

    # Coding standards
    coffeelint:
      components:
        files:
          src: ['components/*.coffee', 'spec/*.coffee']
        options:
          max_line_length:
            value: 80
            level: 'ignore'

    #'node-inspector':
    #  dev: {}

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-mocha-test'
  @loadNpmTasks 'grunt-coffeelint'

  # Grunt plugins used for debugging
  #@loadNpmTasks 'grunt-node-inspector'

  # Our local tasks
  @registerTask 'test', ['coffeelint', 'mochaTest']
  @registerTask 'nodeinsp', ['node-inspector']
  @registerTask 'default', ['test']
