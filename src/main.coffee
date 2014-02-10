http = require 'http'
net = require 'net'
url = require 'url'
{EventEmitter} = require 'events'

Datastore = require 'nedb'

CardManager = require './card-manager'
sendUtils = require './send-utils'
UserStorage = require './users'
ChallengeStorage = require './challenges'

userDb = new Datastore()
userStorage = new UserStorage userDb

challengeDb = new Datastore()
challengeStorage = new ChallengeStorage challengeDb

usernameSockets = {}

userStorage.register 'kayarr', 'boat', (err, user) ->
userStorage.register 'master', 'boat', (err, user) ->
userStorage.register 'strack', 'boat', (err, user) ->

challengeStorage.add sender: 'kayarr', receiver: 'master', ->
challengeStorage.add sender: 'strack', receiver: 'kayarr', ->

CardManager.load './cards', ->

	net.createServer (socket) ->
		sendUtils.extendSocket socket

		socket.on 'close', ->
			username = socket.username
			if username?
				console.log "Logging out #{username}"
				i = usernameSockets[username].indexOf socket
				usernameSockets[username][i..i] = [] if ~i
				
		socket.on 'error', (error) -> (console.error error.stack)

		socket.on 'json-data', (data) -> handleJsonData socket, data

	.listen 6214

handleJsonData = (socket, data) ->
	switch data.type
		when 'register'
			{username, password} = data

			userStorage.register username, password, (err, user) ->
				if err?
					socket.writeJson
						type: 'register'
						success: false
						username: username
						errorCode: err.code ? 'internal-error'
					return

				# registration went fine
				socket.writeJson
					type: 'register'
					success: true
					username: username

		when 'login'
			{username, password} = data

			userStorage.login username, password, (err, user) ->
				if err?
					socket.writeJson
						type: 'login'
						success: false
						username: username
						errorCode: err.code ? 'internal-error'
					return

				# login went fine
				(usernameSockets[username] ?= []).push socket
				socket.username = username

				console.log "Logged in #{username}"

				socket.writeJson
					type: 'login'
					success: true
					username: username

		when 'get-challenges'
			sender = socket.username

			if not sender? # client is not logged in
				socket.writeJson type: 'challenges-list', errorCode: 'not-logged-in'

			else # client is logged in
				challengeStorage.getForUser sender, (err, challenges) ->
					challenges = for challenge in challenges
						sent = challenge.sender is sender

						{
							challengeId: challenge._id
							sent
							username: if sent then challenge.receiver else challenge.sender
						}

					socket.writeJson
						type: 'challenges-list'
						challenges: challenges

		when 'challenge'
			[sender, receiver] = [socket.username, data.username]

			if not sender? # client is not logged in
				socket.writeJson type: 'challenge', username: receiver,
					success: false, errorCode: 'not-logged-in'

				return

			userStorage.isRegistered receiver, (err, registered) ->
				if err?
					console.error err.stack
					socket.writeJson type: 'challenge', username: receiver,
						success: false, errorCode: 'internal-error'

					return

				if registered
					socket.writeJson type: 'challenge', username: receiver,
						success: false, errorCode: 'nonexistant-username'

					return

				challengeStorage.add {sender, receiver}, (err, challenge) ->
					if err?
						console.error err.stack
						socket.writeJson type: 'challenge', username: receiver,
							success: false, errorCode: 'internal-error'

						return

					socket.writeJson type: 'challenge', username: receiver,
						challengeId: challenge._id, success: true

					# tell receiver that they were challenged by the sender

		when 'accept', 'decline'
			reply = data.type

			challengeStorage.getForUser socket.username, (err, challenges) ->
				[challenge, ...] = (c for c in challenges when c._id is data.challengeId)

				console.log challenges

				console.log "User #{socket.username} action: #{reply}:", challenge