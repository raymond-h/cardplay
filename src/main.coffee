http = require 'http'
net = require 'net'
url = require 'url'
{EventEmitter} = require 'events'

CardManager = require './card-manager'
sendUtils = require './send-utils'

recvdEvents = new EventEmitter()

CardManager.load './cards', ->

	net.createServer (socket) ->
		buffer = ""
		dataLengthNeeded = -1

		socket.on 'data', (data) ->
			buffer += data.toString()

			while ([data, startOfNext] = sendUtils.parseSendableJson buffer; data?)
				buffer = buffer.substring startOfNext

				socket.emit 'json-data', data

		socket.on 'json-data', (data) -> recvdEvents.emit data.type, socket, data

	.listen 6214

recvdEvents.on 'register', (socket, data) ->
	{username, password} = data

	console.log "Registering user #{username} with password #{password}"

recvdEvents.on 'login', (socket, data) ->
	{username, password} = data