_ = require 'underscore'
{EventEmitter} = require 'events'

class Session extends EventEmitter
	constructor: (@players, @turn = 0, @round = 1) ->
		Object.defineProperty @, 'currentPlayer',
			get: => @players[@turn]

	progressTurn: ->
		@turn++
		if @turn >= @players.length
			@turn = 0
			@round++
		# emit events regarding turn and round changes

	toJSON: ->
		json = {
			@turn, @round

			players: (p.toJSON() for p in @players)
		}

		json._id = @id if @id?

		json

	@fromJSON: (json, cardManager) ->
		players = (Player.fromJSON p, cardManager for p in json.players)

		new Session players, json.turn, json.round

class Field
	constructor: (@width = 6, @height = 2) ->
		@field = (null for x in [0...@width] for y in [0...@height])

	put: (instance, x, y) ->
		@field[y][x] = instance
		# emit event

	toJSON: ->
		{
			width: @width
			height: @height
			field: for row, y in @field
				for v, x in row
					if not v? then null

					else {
						card: v.card.id
						health: v.health
					}
		}

	@fromJSON: (json, cardManager) ->
		{width, height} = json
		field = new Field width, height

		field.field = for row, y in json.field
			for v, x in row
				if not v? then null

				else
					inst = cardManager.cards[v.card].newInstance()

					if v.health?
						inst.health.current = v.health.current
						inst.health.max = v.health.max

					inst

		field

class Player
	constructor: (@username, @field = null) ->
		@deck = []
		@hand = []
		@discard = []
		@health = {}

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

	toJSON: ->
		{
			username: @username,
			deck: @deck, hand: @hand,
			discard: @discard,
			field: @field.toJSON()
		}

	@fromJSON: (json, cardManager) ->
		field = Field.fromJSON json.field, cardManager

		_.extend (new Player json.username, field),
			_.pick json, 'deck', 'hand', 'discard'

class Card extends EventEmitter
	constructor: (config) ->
		_.extend @, config

	newInstance: ->
		inst = { card: @ }

		inst.health = new Health @maxHealth if @type is 'unit'

		inst

class Health
	constructor: (@max, @current = @max) ->

		Object.defineProperties @,
			'multiplier':
				get: -> @current / @max
				set: (mult) -> @current = @max * mult

			'atMin': get: -> @current <= 0
			'atMax': get: -> @current >= @max

module.exports = {Session, Field, Card, Player, Health}