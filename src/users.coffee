NedbDatastore = require 'nedb'

class UserStorage
	constructor: (path) ->
		@db = new NedbDatastore filename: path, autoload: true

	register: (username, password, callback) ->
		# callback: (err, user)
		
		@db.insert { username, password }, callback

	login: (username, password, callback) ->
		# callback: (err, user)

		callback null

	get: (username, callback) ->
		# callback: (err, user)

		@db.findOne { username }, callback

	close: ->

module.exports = UserStorage