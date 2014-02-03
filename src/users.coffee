NedbDatastore = require 'nedb'

class User
	constructor: (@username, @password) ->

class UserStorage
	constructor: (path) ->
		@db = new NedbDatastore filename: path, autoload: true

	register: (username, password, callback) ->
		# callback: (err, user)
		
		@db.insert { username, password }, (err, changedRows) ->
			if err? then callback err

			else
				callback null, new User username, password

	login: (username, password, callback) ->
		# callback: (err, user)

		callback null

	get: (username, callback) ->
		# callback: (err, user)

		@db.findOne { username }, callback

	close: ->

module.exports = UserStorage