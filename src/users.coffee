class UserStorage
	register: (username, password, callback) -> callback null

	login: (username, password, callback) -> callback null

	get: (username, callback) -> callback null

	clear: (callback) -> callback null

	close: ->

NedbDatastore = require 'nedb'

class NedbUserStorage extends UserStorage
	constructor: (path) ->
		@db = new NedbDatastore filename: path, autoload: true

	register: (username, password, callback) ->
		@db.insert { username, password }, callback

	login: (username, password, callback) -> callback null

	get: (username, callback) ->
		@db.findOne { username }, callback

	clear: (callback) ->
		@db.remove {}, callback

module.exports = NedbUserStorage