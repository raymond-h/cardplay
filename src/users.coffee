NedbDatastore = require 'nedb'

class UserStorage
	constructor: (path) ->
		@db = new NedbDatastore filename: path, autoload: true

	register: (username, password, callback) ->
		@db.insert { username, password }, callback

	login: (username, password, callback) ->
		callback null

	close: ->

module.exports = UserStorage