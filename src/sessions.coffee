{Session, Field, Card, Player} = require './game'

class SessionStorage
	constructor: (@db) ->

	getForUser: (username, callback) ->
		# callback: (err, sessions array of object literals)

	new: (usernames, callback) ->
		# callback: (err, session instance)

	load: (id, callback) ->
		# callback: (err, session instance)

	save: (session, callback) ->
		# callback: (err)

module.exports = SessionStorage