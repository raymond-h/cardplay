_ = require 'underscore'

{Session, Field, Card, Player, Health} = require './game'

class SessionStorage
	constructor: (@db, @cardManager) ->

	getForUser: (username, callback) ->
		# callback: (err, sessions array of object literals)

		@db.find { "players.username": username }, callback

	new: (usernames, callback) ->
		# callback: (err, session instance)
		players = for username in usernames
			new Player username,
				field: new Field
				health: new Health 500

				hand: [], deck: [], discard: []

		session = new Session players

		@db.insert session.toJSON(), (err, doc) ->
			if err? then callback err
			else
				session.id = doc._id
				callback null, session

	load: (id, callback) ->
		# callback: (err, session instance)

		@db.findOne _id: id, (err, doc) =>
			if err? then callback err
			else
				if not doc?
					callback _.extend new Error("No session with the ID '#{id}' exists"),
						code: 'nonexistant-session'
						id: id
				else
					session = Session.fromJSON doc, @cardManager
					callback null, session

	save: (session, callback) ->
		# callback: (err)

		@db.update { _id: session.id }, session.toJSON(),
			(err, numReplaced, newDoc) ->
				return callback err if err?

				callback (
					if numReplaced is 0
						_.extend new Error(
							"The session does not match any registered session"),
							code: 'nonexistant-session'
					else
						null
				)

module.exports = SessionStorage