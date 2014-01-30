_ = require 'underscore'
{EventEmitter} = require 'events'

class Session

class Field

class Player

class Card extends EventEmitter
	constructor: (config) ->
		_.extend @, config

exports.Card = Card
exports.Session = Session
exports.Field = Field
exports.Player = Player