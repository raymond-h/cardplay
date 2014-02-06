NedbDatastore = require 'nedb'
_ = require 'underscore'

class ChallengeStorage
	constructor: (path) ->
		@db = new NedbDatastore filename: path, autoload: true

	getForUser: (username, callback) ->
		@db.find $or: [ (sender: username), (receiver: username) ], (err, rows) ->
			return callback err if err?

			callback null, rows

	add: (params, callback) ->
		# callback: (err, challenge)

		@db.insert { sender: params.sender, receiver: params.receiver }, callback

module.exports = ChallengeStorage