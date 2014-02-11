_ = require 'underscore'
{EventEmitter} = require 'events'

class Session extends EventEmitter
	constructor: (@players) ->
		p.session = @ for p in @players

		@turn = 0
		@round = 1

		Object.defineProperty @, 'currentPlayer',
			get: => @players[@turn]

	progressTurn: ->
		@turn++
		if @turn >= @players.length
			@turn = 0
			@round++
		# emit events regarding turn and round changes

	newInstance: (owner, card) ->
		# create new object repr. an instance of passed-in card
		{
			card
			owner
			session: @
			health: {}
		}

class Field
	constructor: (@owner, @width = 6, @height = 2) ->
		@field = (null for y in [0...height] for x in [0...width])

	put: (instance, x, y) ->
		@field[x][y] = instance
		# emit event

class Player
	constructor: (@username) ->
		@deck = []
		@hand = []
		@discard = []
		@health = {}
		@field = null

	playCard: (instance, x, y) ->
		return if this isnt @session.currentPlayer # if it isn't our turn, bail out

		# assuming instance exists on hand for now...
		i = @hand.indexOf instance
		@hand[i..i] = []

		switch instance.card.type
			when 'unit'
				# place unit at position x,y
				@field.put instance, x, y
				
			when 'action'
				# perform action (x, y are unused)
				# move to discard pile
				discard.push instance

class Card extends EventEmitter
	constructor: (config) ->
		_.extend @, config

module.exports = {Session, Field, Card, Player}