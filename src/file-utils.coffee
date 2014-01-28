path = require 'path'
fs = require 'fs'
_ = require 'underscore'

walkFolder = (folder, callback, done) ->
	fs.readdir folder, (err, files) ->
		if err?
			callback err
			done()
			return

		if files.length is 0
			done?()
			return

		finish = _.after files.length, ->
			done?()

		for file in files
			fullPath = path.resolve folder, file

			do (finish, fullPath) ->
				fs.stat fullPath, (err, stats) ->
					if err?
						callback err
						finish()
						return

					if stats.isDirectory()
						walkFolder fullPath, callback, finish

					else if stats.isFile()
						callback null, fullPath
						finish()

					else finish()

module.exports = {walkFolder}