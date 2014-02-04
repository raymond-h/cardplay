http = require 'http'
net = require 'net'
url = require 'url'
{EventEmitter} = require 'events'

CardManager = require './card-manager'
sendUtils = require './send-utils'
UserStorage = require './users'

userStorage = new UserStorage()

usernameSockets = {}

CardManager.load './cards', ->

	recvdEvents = new EventEmitter()

	net.createServer (socket) ->
		sendUtils.extendSocket socket

		socket.on 'json-data', (data) -> recvdEvents.emit data.type, socket, data

		socket.on 'end', ->
			username = socket.username
			if username?
				console.log "Logging out #{username}"
				i = usernameSockets[username].indexOf socket
				usernameSockets[username][i..i] = [] if ~i

	.listen 6214

	recvdEvents.on 'register', (socket, data) ->
		{username, password} = data

		userStorage.register username, password, (err, user) ->
			if err?
				socket.writeJson
					type: 'register'
					success: false
					username: username
					errorCode: err.code ? 'internal-error'

			else
				# registration went fine
				socket.writeJson
					type: 'register'
					success: true
					username: username

	recvdEvents.on 'login', (socket, data) ->
		{username, password} = data

		userStorage.login username, password, (err, user) ->
			if err?
				socket.writeJson
					type: 'login'
					success: false
					username: username
					errorCode: err.code ? 'internal-error'

			else
				# login went fine
				(usernameSockets[username] ?= []).push socket
				socket.username = username

				console.log "Logged in #{username}"

				socket.writeJson
					type: 'login'
					success: true
					username: username