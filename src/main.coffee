http = require 'http'
net = require 'net'
url = require 'url'
Router = require 'routes'

CardManager = require './card-manager'
sendUtils = require './send-utils'

CardManager.load './cards', ->

	net.createServer (socket) ->
		buffer = ""
		dataLengthNeeded = -1

		socket.on 'data', (data) ->
			buffer += data.toString()

			while ([data, startOfNext] = sendUtils.parseSendableJson buffer; data?)
				buffer = buffer.substring startOfNext

				socket.emit 'json-data', data

		socket.on 'json-data', (data) ->
			console.log "Got data", data

	.listen 6214