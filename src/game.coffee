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

	putDown: (instance, x, y) ->
		@field[y][x] = {
			instance
			card: instance.card

			health: new Health instance.maxHealth
		}
		# emit event

	pickUp: (x, y) ->
		unit = @field[y][x]

		@field[y][x] = null

		return unit.instance

	toJSON: ->
		{
			width: @width
			height: @height
			field: for row, y in @field
				for v, x in row
					if not v? then null

					else {
						card: v.card.id
						health:
							current: v.health.current
							max: v.health.max
					}
		}

	@fromJSON: (json, cardManager) ->
		{width, height} = json
		field = new Field width, height

		field.field = for row, y in json.field
			for v, x in row
				if not v? then null

				else
					instance = cardManager.cards[v.card].newInstance()

					unit = {
						instance
						card: instance.card

						health: new Health v.health.max, v.health.current
					}

					unit

		field

class Player
	constructor: (@username, params) ->
		{@deck, @hand, @discard, @health, @field} = params

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
		# console.log @
		{
			username: @username

			deck: @deck, hand: @hand
			discard: @discard

			health:
				current: @health.current
				max: @health.max

			field: @field.toJSON()
		}

	@fromJSON: (json, cardManager) ->
		params =
			field: Field.fromJSON json.field, cardManager
			health: new Health json.health.max, json.health.current

			hand: json.hand
			deck: json.deck
			discard: json.discard

		new Player json.username, params

class Card extends EventEmitter
	constructor: (config) ->
		_.extend @, config

	newInstance: ->
		inst = new Object @

		inst.card = @

		return inst

class Health
	constructor: (@max, @current = @max) ->

		Object.defineProperties @,
			'multiplier':
				get: -> @current / @max
				set: (mult) -> @current = @max * mult

			'atMin': get: -> @current <= 0
			'atMax': get: -> @current >= @max

module.exports = {Session, Field, Card, Player, Health}