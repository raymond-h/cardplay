NedbDatastore = require 'nedb'

class User
	constructor: (@username, @password) ->

class UserStorageError extends Error
	constructor: (@message, @code) ->
		super message

class UserStorage
	constructor: (path) ->
		@db = new NedbDatastore filename: path, autoload: true

		@loggedInUsers = []

	validateUsername: (username) ->
		/^[a-zA-Z_-]+$/.test username

	register: (username, password, callback) ->
		# callback: (err, user)

		if not @validateUsername username
			callback new UserStorageError "Invalid username '#{username}'", 'invalid-username'
		
		else @db.insert { username, password }, callback

	login: (username, password, callback) ->
		# callback: (err, user)

		@get username, (err, user) =>
			if err? then callback err; return

			if user.password is password
				@loggedInUsers.push username
				callback null, { username, password }

			else
				callback new UserStorageError 'Invalid username or password', 'username-password-invalid'

	get: (username, callback) ->
		# callback: (err, user)

		@db.findOne { username }, callback

	clear: (callback) ->
		@db.remove {}, callback

	close: ->

module.exports = UserStorage
module.exports.Error = UserStorageError