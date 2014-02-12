{Session, Field, Card, Player} = require './game'

class SessionStorage
	constructor: (@db) ->

	getForUser: (username, callback) ->
		# callback: (err, sessions array of object literals)

	new: (usernames, callback) ->
		# callback: (err, session instance)
		players = new Player u for u in usernames
		session = new Session players

		@db.insert session, (err) ->
			if err? then callback err
			else callback null, session

	load: (id, callback) ->
		# callback: (err, session instance)

	save: (session, callback) ->
		# callback: (err)

module.exports = SessionStorage