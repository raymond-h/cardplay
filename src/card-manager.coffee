path = require 'path'
fs = require 'fs'
_ = require 'underscore'
CoffeeScript = require 'coffee-script'
vm = require 'vm'
               
fileUtils = require './file-utils'
game = require './game'
{Card} = game

exports.getJsSource = getJsSource = (file) ->
	file = path.resolve file
	contents = fs.readFileSync file, encoding: 'utf-8'

	switch path.extname file
		when '.js' then return contents

		when '.coffee', '.lit-coffee', '.coffee.md'
			try
				return CoffeeScript.compile contents, filename: file
			catch e
				console.error e.stack

class CardManager
	constructor: () ->
		@cards = {}

	loadScript: (code, file) ->
		readyCallback = ->

		sandbox =
			ready: (callback) -> readyCallback = callback
			console: console

		vm.runInNewContext code, sandbox, file

		readyCallback (type, config) =>
			if typeof type is 'string' and config? then config.type = type

			@cards[config.id] = new Card config # also returns the created card

	loadFile: (file) ->
		file = path.resolve file
		source = getJsSource file

		@loadScript source, file

	loadFolder: (folder, callback) ->
		fileUtils.walkFolder folder, (err, file) =>
			if err?
				console.error err.stack
				return

			if (path.extname file) in ['.js', '.coffee', '.litcoffee', '.coffee.md']
				@loadFile file

		, callback

module.exports = {CardManager}