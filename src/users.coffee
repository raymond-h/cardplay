NedbDatastore = require 'nedb'

class UserStorageError extends Error
	constructor: (@message, @code) ->
		super message

class UserStorage
	constructor: (@db) ->
		@loggedInUsers = []

	validateUsername: (username) ->
		/^[a-zA-Z_-]+$/.test username

	register: (username, password, callback) ->
		# callback: (err, user)

		if not @validateUsername username
			callback new UserStorageError "Invalid username '#{username}'",
				'invalid-username'
		
		else @db.count { username }, (err, count) =>
			return callback err if err?
			
			if count > 0
				callback new UserStorageError "Username '#{username}' is already taken",
					'username-taken'

			else @db.insert { username, password }, callback

	login: (username, password, callback) ->
		# callback: (err, user)

		@get username, (err, user) =>
			return callback err if err?

			if user? and user.password is password
				@loggedInUsers.push username if not (username in @loggedInUsers)
				callback null, { username, password }

			else
				callback new UserStorageError 'Invalid username or password',
					'username-password-invalid'

	get: (username, callback) ->
		# callback: (err, user)

		@db.findOne { username }, callback

	clear: (callback) ->
		@db.remove {}, callback

	close: ->

module.exports = UserStorage
module.exports.Error = UserStorageError