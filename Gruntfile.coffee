module.exports = (grunt) ->

	grunt.task.loadNpmTasks 'grunt-contrib-coffee'
	grunt.task.loadNpmTasks 'grunt-coffeelint'
	grunt.task.loadNpmTasks 'grunt-contrib-watch'

	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'

		coffee:
			build:
				expand: yes
				cwd: 'src/'
				src: '*.coffee'
				dest: 'lib/'
				ext: '.js'

		coffeelint:
			build:
				files: src: ['src/*.coffee']
			options:
				no_tabs: level: 'ignore'
				indentation: level: 'ignore'

		watch:
			lint:
				files: ['src/*.coffee']
				tasks: ['lint']

	grunt.registerTask 'default', ["build"]

	grunt.registerTask 'build', ['coffeelint:build', 'coffee:build']
	grunt.registerTask 'lint', ['coffeelint:build']

	grunt.registerTask 'dev', ['watch:lint']