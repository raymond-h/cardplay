_ = require 'underscore'
{EventEmitter} = require 'events'

class Card extends EventEmitter
	constructor: (config) ->
		_.extend @, config

exports.Card = Card