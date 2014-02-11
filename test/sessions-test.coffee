chai = require 'chai'

{expect} = chai
chai.should()

describe 'SessionStorage', ->
	describe '.getForUser()', ->
		it 'should return an array of sessions for a give user'

		it 'should return an error if the given user is not registered'

	describe '.new()', ->
		it 'should create a new Session object, save it and return it'

		it 'should return an error if the given user names are not registered'

	describe '.load()', ->
		it 'should create a Session object from a document with the given ID'

		it 'should return an error if the given ID does not exist'

	describe '.save()', ->
		it 'should persist the given Session object by its ID'

		it 'should return an error if the given session\'s ID does not exist already'