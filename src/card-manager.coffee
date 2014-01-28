path = require 'path'
fs = require 'fs'
_ = require 'underscore'
CoffeeScript = require 'coffee-script'
{EventEmitter} = require 'events'

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

class Card extends EventEmitter
	constructor: (@type, config) ->
		_.extend @, config

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
		console: console

	vm.runInNewContext code, sandbox, file

	cards = []

	readyCallback (type, config) ->
		if not config? then [config, type] = [type, type.type]
		cards.push (c = new Card type, config)
		return c

	console.log "Added", cards

exports.load = (folder, callback) ->
	fileUtils.walkFolder folder, (err, file) ->
		if err? then console.error err.stack

		# console.log "Got file #{file} with extension #{path.extname file}"
		if (path.extname file) in ['.js', '.coffee', '.lit-coffee', '.coffee.md']
			loadScript file

	, callback