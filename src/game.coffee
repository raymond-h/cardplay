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

	@serializeField: (field) ->
		{
			width: field.width
			height: field.height
			field: for row, y in field.field
				for v, x in row
					if not v? then null

					else {
						card: v.card.id
						health: {
							current: v.health.current
							max: v.health.max
						}
					}
		}

	@deserializeField: (json) ->
		{width, height} = json
		field = new Field width, height

		field.field = for row, y in json.field
			for v, x in row
				if not v? then null

				else {
					card: v.card.id
					health: {
						current: v.health.current
						max: v.health.max
					}
				}

		field

	toJSON: ->
		{
			@turn, @round

			players: {
				username: p.username,
				deck: p.deck, hand: p.hand,
				discard: p.discard,
				field: Session.serializeField p.field
			} for p in @players
		}

	@fromJSON: (json) ->
		players = for p in json.players
			field = Session.deserializeField p.field

			_.extend (new Player p.username, field),
				_.pick p, 'deck', 'hand', 'discard'

		new Session players

class Field
	constructor: (@width = 6, @height = 2) ->
		@field = (null for x in [0...@width] for y in [0...@height])

	put: (instance, x, y) ->
		@field[y][x] = instance
		# emit event

class Player
	constructor: (@username, @field = null) ->
		@deck = []
		@hand = []
		@discard = []
		@health = {}

		@field.owner = @ if @field?

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

class Health
	constructor: (@max, @current = @max) ->

		Object.defineProperties @,
			'multiplier':
				get: -> @current / @max
				set: (mult) -> @current = @max * mult

			'atMin': get: -> @current <= 0
			'atMax': get: -> @current >= @max

module.exports = {Session, Field, Card, Player, Health}