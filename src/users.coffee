class UserStorage

NedbDatastore = require 'nedb'

class NedbUserStorage extends UserStorage
	constructor: (path) ->
		@db = new NedbDatastore filename: path, autoload: true

module.exports = NedbUserStorage