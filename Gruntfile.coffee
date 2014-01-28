module.exports = (grunt) ->

	grunt.task.loadNpmTasks 'grunt-contrib-coffee'
	grunt.task.loadNpmTasks 'grunt-coffeelint'

	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'

		coffee:
			build:
				files: 'lib/*.js': 'src/*.coffee'

		coffeelint:
			build:
				files: src: ['src/*.coffee']

	grunt.registerTask 'default', ["build"]

	grunt.registerTask 'build', ['coffeelint:build', 'coffee:build']
	grunt.registerTask 'lint', ['coffeelint:build']