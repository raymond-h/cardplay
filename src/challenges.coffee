class ChallengeStorage
	constructor: (@db) ->

	getForUser: (username, callback) ->
		# callback: (err, challenges)

		@db.find $or: [ (sender: username), (receiver: username) ], (err, rows) ->
			return callback err if err?

			callback null, rows

	add: (params, callback) ->
		# callback: (err, challenge)

		@db.insert { sender: params.sender, receiver: params.receiver }, callback

	remove: (id, callback) ->
		# callback: (err)

		@db.remove { _id: id }, callback

module.exports = ChallengeStorage