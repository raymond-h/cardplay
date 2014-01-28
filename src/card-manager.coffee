path = require 'path'
fs = require 'fs'
CoffeeScript = require 'coffee-script'

fileUtils = require './file-utils'

getJsSource = (file) ->
	file = path.resolve file
	contents = fs.readFileSync file, encoding: 'utf-8'

	switch path.extname file
		when '.js' then return contents

		when '.coffee', '.lit-coffee', '.coffee.md'
			console.log "Compiling Coffeescript file..."

			try
				return CoffeeScript.compile contents, filename: file
			catch e
				console.error e.stack

loadScript = (file, callback) ->
	file = path.resolve file
	source = getJsSource file

	runScript source, file, -> callback()

runScript = (code, file, callback) ->
	vm = require 'vm'

	prereqs = []
	readyCallback = ->

	sandbox =
		ready: (callback) -> readyCallback = callback

	vm.runInNewContext code, sandbox, file

	readyCallback -> { on: -> }

exports.load = (folder, callback) ->
	fileUtils.walkFolder folder, (err, file) ->
		if err? then console.error err.stack

		# console.log "Got file #{file} with extension #{path.extname file}"
		if (path.extname file) in ['.js', '.coffee', '.lit-coffee', '.coffee.md']
			loadScript file
	, callback