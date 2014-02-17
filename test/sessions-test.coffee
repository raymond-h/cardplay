chai = require 'chai'
{asyncCatch} = require './common'

{expect} = chai
chai.should()

Datastore = require 'nedb'
Q = require 'q'
_ = require 'underscore'

describe 'SessionStorage', ->
	{Session, Player, Field, Health} = require '../src/game'
	SessionStorage = require '../src/sessions'
	datastore = db = null

	before ->
		datastore = new Datastore()
		db = new SessionStorage datastore

	afterEach (done) ->
		datastore.remove {}, multi: yes, done

	describe '.getForUser()', ->
		it 'should return an array of sessions for a given user', (done) ->
			db.new ['kayarr', 'master'], (err, s1) ->
				return done err if err?
				db.new ['boat', 'kayarr'], (err, s2) ->
					return done err if err?

					db.getForUser 'kayarr', asyncCatch(done) (err, sessions) ->
						throw err if err?

						expect(sessions).to.exist
						sessions.should.be.an('array').and.have.length 2

						s1loaded = _.find sessions, (s) -> s._id is s1.id
						s2loaded = _.find sessions, (s) -> s._id is s2.id

						expect(s1loaded).to.deep.equal s1.toJSON()
						expect(s2loaded).to.deep.equal s2.toJSON()

						done()

		# it 'should return an error if the given user is not registered'

	describe '.new()', ->
		it 'should create a new Session object, save it and return it',
		(done) ->

			db.new ['kayarr', 'master'], asyncCatch(done) (err, session) ->
				throw err if err?

				expect(err).to.not.exist
				expect(session).to.exist.and.be.instanceof Session
				session.should.contain.keys 'id'

				datastore.findOne { _id: session.id }, asyncCatch(done) (err, doc) ->
					throw err if err?

					expect(doc).to.exist
					doc.should.contain.keys 'turn', 'round', 'players'
					doc.players.should.have.length 2

					done()

		# it 'should return an error if the given user names are not registered'

	describe '.load()', ->
		it 'should create a Session object from a document with the given ID',
		(done) ->
			db.new ['kayarr', 'master'], (err, session) ->
				return done err if err?

				db.load session.id, asyncCatch(done) (err, session) ->
					throw err if err?

					expect(session).to.exist.and.be.instanceof Session

					done()

		it 'should return an error if the given ID does not exist', (done) ->
			db.load 'HUMBUGUU', asyncCatch(done) (err, session) ->

				expect(err).to.exist.and.be.instanceof Error
				expect(session).to.not.exist

				err.should.have.property 'id', 'HUMBUGUU'
				err.should.have.property 'code', 'nonexistant-session'
				err.message.should.equal "No session with the ID 'HUMBUGUU' exists"

				done()

	describe '.save()', ->
		it 'should persist the given Session object by its ID', (done) ->
			db.new ['kayarr', 'boat'], (err, session) ->
				return done err if err?

				session.progressTurn() for i in [1..11] # progress 11 turns
				# turn is 1, round is 6

				db.save session, asyncCatch(done) (err) ->
					return done err if err?

					datastore.findOne {}, asyncCatch(done) (err, doc) ->
						throw err if err?

						doc.should.have.property 'turn', 1
						doc.should.have.property 'round', 6
						doc.players.should.be.length 2

						done()
					
		it 'should return an error if the given session\'s ID
			does not exist already', (done) ->
				
			session = new Session [
				new Player 'kayarr',
					field: new Field
					health: new Health 500
					hand: [], deck: [], discard: []

				new Player 'master',
					field: new Field
					health: new Health 500
					hand: [], deck: [], discard: []
			]

			session.progressTurn() for i in [1..11] # progress 11 turns
			# turn is 1, round is 6

			db.save session, asyncCatch(done) (err) ->

				expect(err).to.exist.and.be.instanceof Error
				err.message.should.equal(
					"The session does not match any registered session"
				)
				err.should.have.property 'code', 'nonexistant-session'
				
				done()