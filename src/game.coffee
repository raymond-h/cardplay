_ = require 'underscore'
{EventEmitter} = require 'events'

class Session

class Field

class Player

class Card extends EventEmitter
	constructor: (config) ->
		_.extend @, config

module.exports = {Session, Field, Card, Player}