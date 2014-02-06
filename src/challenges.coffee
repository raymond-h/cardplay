_ = require 'underscore'

class ChallengeStorage
	constructor: (@db) ->

	getForUser: (username, callback) ->
		@db.find $or: [ (sender: username), (receiver: username) ], (err, rows) ->
			return callback err if err?

			callback null, rows

	add: (params, callback) ->
		# callback: (err, challenge)

		@db.insert { sender: params.sender, receiver: params.receiver }, callback

module.exports = ChallengeStorage