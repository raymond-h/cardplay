module.exports = (grunt) ->

	grunt.task.loadNpmTasks 'grunt-contrib-coffee'
	grunt.task.loadNpmTasks 'grunt-coffeelint'
	grunt.task.loadNpmTasks 'grunt-contrib-watch'
	grunt.task.loadNpmTasks 'grunt-mocha-test'

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
				files: src: ['src/**/*.coffee', 'test/**/*.coffee']
			options:
				no_tabs: level: 'ignore' # this is tab land, boy
				indentation: value: 1 # single tabs

		mochaTest:
			test:
				options:
					reporter: 'spec'
					require: ['coffee-script/register']

				src: ['test/**/*.coffee']

		watch:
			lint:
				files: ['src/*.coffee', 'test/*.coffee']
				tasks: ['lint', 'test']

	grunt.registerTask 'default', ["build"]

	grunt.registerTask 'build', ['lint', 'test', 'coffee:build']
	grunt.registerTask 'dev', ['lint', 'test']

	grunt.registerTask 'lint', ['coffeelint:build']
	grunt.registerTask 'test', ['mochaTest:test']

	grunt.registerTask 'watch-dev', ['watch:lint']