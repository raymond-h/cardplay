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
		
		else @isRegistered username, (err, registered) =>
			return callback err if err?
			
			if registered
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

	logout: (username, callback) ->
		# callback: (err)

		if username in @loggedInUsers
			i = @loggedInUsers.indexOf username
			@loggedInUsers[i..i] = []

			callback null

		else
			callback new UserStorageError "Username '#{username}' is not logged in",
				'not-logged-in'

	get: (username, callback) ->
		# callback: (err, user)

		@db.findOne { username }, callback

	isRegistered: (username, callback) ->
		# callback: (err, registered)

		@db.count { username }, (err, count) ->
			if err? then callback err

			else callback null, (count > 0)

	isLoggedIn: (username, callback) ->
		# callback: (err, loggedIn)

		if username in @loggedInUsers then callback null, true

		else @isRegistered username, (err, registered) ->
			return callback err if err?

			if not registered
				callback new UserStorageError "Username '#{username}' does not exist",
					'invalid-username'

			else callback null, false

	close: ->

module.exports = UserStorage
module.exports.Error = UserStorageError