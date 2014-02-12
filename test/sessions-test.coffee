chai = require 'chai'

{expect} = chai
chai.should()

Datastore = require 'nedb'
Q = require 'q'

describe 'SessionStorage', ->
	{Session} = require '../src/game'
	SessionStorage = require '../src/sessions'
	datastore = db = null

	before ->
		datastore = new Datastore()
		db = new SessionStorage datastore

	beforeEach (done) ->
		datastore.remove {}, done

	describe '.getForUser()', ->
		it 'should return an array of sessions for a give user'

		it 'should return an error if the given user is not registered'

	describe '.new()', ->
		it.skip 'should create a new Session object, save it and return it',
		(done) ->

			db.new ['kayarr', 'master'], (err, session) ->
				try
					throw err if err?

					expect(err).to.not.exist
					expect(session).to.exist.and.be.instanceof Session

					datastore.count {}, (err, count) ->
						try
							throw err if err?
							count.should.equal 1, 'expected datastore to
											contain an item'
							done()

						catch e then done e

				catch e then done e

		it 'should return an error if the given user names are not registered'

	describe '.load()', ->
		it 'should create a Session object from a document with the given ID'

		it 'should return an error if the given ID does not exist'

	describe '.save()', ->
		it 'should persist the given Session object by its ID'

		it 'should return an error if the given session\'s ID does not exist already'