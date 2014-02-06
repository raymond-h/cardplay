chai = require 'chai'

{expect} = chai
chai.should()

fs = require 'fs'
Q = require 'q'
rimraf = require 'rimraf'
Datastore = require 'nedb'

describe 'UserStorage', ->
	UserStorage = require '../src/users'
	db = null

	before ->
		userDb = new Datastore()
		db = new UserStorage userDb

	beforeEach (done) ->
		db.loggedInUsers = []
		db.clear done

	describe '.validateUsername()', ->
		it 'should allow usernames with only alphabetical symbols and/or _-', ->
			db.validateUsername('kay_arr-two').should.be.true

		it 'should disallow usernames with other symbols', ->
			db.validateUsername('WOAHBRO()').should.be.false
			db.validateUsername('Num5658465').should.be.false

		it 'should disallow an empty username', ->
			db.validateUsername('').should.be.false

	describe '.register()', ->
		it 'should add users with valid username and password', (done) ->
			Q.ninvoke db, 'register', 'kayarr', 'boat'

			.then (user) ->
				expect(user).to.exist
				user.should.have.property 'username', 'kayarr'
				user.should.have.property 'password', 'boat'

			.then -> Q.ninvoke db, 'get', 'kayarr'

			.then (user) ->
				expect(user).to.exist
				user.should.have.property 'username', 'kayarr'
				user.should.have.property 'password', 'boat'

			.nodeify done

		it 'should return an error if given an invalid username', (done) ->
			db.register 'U#(YTU =¤WITWYHUOcrazy', 'hahah', (err, user) ->
				expect(err).to.exist.and.be.an.instanceof Error
				err.should.have.property 'code', 'invalid-username'
				err.message.should.equal "Invalid username 'U#(YTU =¤WITWYHUOcrazy'"
				expect(user).to.not.exist
				done()

		it 'should return an error if a username is already taken', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?

				db.register 'kayarr', 'boat', (err, user) ->
					expect(err).to.exist.and.be.instanceof Error
					err.should.have.property 'code', 'username-taken'
					err.message.should.equal "Username 'kayarr' is already taken"
					expect(user).to.not.exist

					done()

	describe '.login()', ->
		it 'should mark user as logged in if username and password are correct', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?

				db.login 'kayarr', 'boat', (err, user) ->
					expect(err).to.not.exist
					expect(user).to.exist

					user.should.deep.equal { username: 'kayarr', password: 'boat' }

					db.loggedInUsers.should.contain 'kayarr'

					done()

		it 'should return an error if the password is wrong', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?

				db.login 'kayarr', 'woah', (err, user) ->
					expect(err).to.exist.and.be.instanceof Error
					err.should.have.property 'code', 'username-password-invalid'
					err.message.should.equal 'Invalid username or password'
					expect(user).to.not.exist

					db.loggedInUsers.should.not.contain 'kayarr'

					done()

		it 'should return an error if given a nonexistant user', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?

				db.login 'woot', 'boat', (err, user) ->
					expect(err).to.exist.and.be.instanceof Error
					err.should.have.property 'code', 'username-password-invalid'
					err.message.should.equal 'Invalid username or password'
					expect(user).to.not.exist

					db.loggedInUsers.should.not.contain ['kayarr', 'woot']

					done()