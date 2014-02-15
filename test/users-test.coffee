chai = require 'chai'
{asyncCatch} = require './common'

{expect} = chai
chai.should()

fs = require 'fs'
Q = require 'q'
rimraf = require 'rimraf'
Datastore = require 'nedb'

describe 'UserStorage', ->
	UserStorage = require '../src/users'
	userDb = null
	db = null

	before ->
		userDb = new Datastore()
		db = new UserStorage userDb

	beforeEach (done) ->
		userDb.remove {}, done

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
				user.should.have.property 'loggedIn', false

			.nodeify done

		it 'should return an error if given an invalid username', (done) ->
			db.register 'U#(YTU =¤WITWYHUOcrazy', 'hahah',
				asyncCatch(done) (err, user) ->

					expect(err).to.exist.and.be.an.instanceof Error
					err.should.have.property 'code', 'invalid-username'
					err.message.should.equal "Invalid username 'U#(YTU =¤WITWYHUOcrazy'"
					expect(user).to.not.exist

					done()

		it 'should return an error if a username is already taken', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?

				db.register 'kayarr', 'boat', asyncCatch(done) (err, user) ->

					expect(err).to.exist.and.be.instanceof Error
					err.should.have.property 'code', 'username-taken'
					err.message.should.equal "Username 'kayarr' is already taken"
					expect(user).to.not.exist

					done()

	describe '.login()', ->
		it 'should mark user as logged in if username and password are correct',
			(done) ->
				db.register 'kayarr', 'boat', (err, user) ->
					return done err if err?

					db.login 'kayarr', 'boat', asyncCatch(done) (err, user) ->

						expect(err).to.not.exist
						expect(user).to.exist

						user.should.deep.equal { username: 'kayarr', password: 'boat' }

						db.get 'kayarr', asyncCatch(done) (err, user) ->

							user.loggedIn.should.be.true

							done()

		it 'should return an error if the password is wrong', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?

				db.login 'kayarr', 'woah', asyncCatch(done) (err, user) ->

					expect(err).to.exist.and.be.instanceof Error
					err.should.have.property 'code', 'username-password-invalid'
					err.message.should.equal 'Invalid username or password'
					expect(user).to.not.exist

					db.isLoggedIn 'kayarr', asyncCatch(done) (err, loggedIn) ->
						throw err if err?

						loggedIn.should.be.false

						done()

		it 'should return an error if given a nonexistant user', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?

				db.login 'woot', 'boat', asyncCatch(done) (err, user) ->

					expect(err).to.exist.and.be.instanceof Error
					err.should.have.property 'code', 'username-password-invalid'
					err.message.should.equal 'Invalid username or password'
					expect(user).to.not.exist

					db.isLoggedIn 'kayarr', asyncCatch(done) (err, loggedIn) ->
						throw err if err?

						loggedIn.should.be.false

						done()

	describe '.logout()', ->
		it 'should log a user out if logged in', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?
				db.login 'kayarr', 'boat', (err, user) ->
					return done err if err?

					db.logout 'kayarr', asyncCatch(done) (err) ->
						expect(err).to.not.exist
						
						db.isLoggedIn 'kayarr', asyncCatch(done) (err, loggedIn) ->
							throw err if err?

							loggedIn.should.be.false

							done()

		it 'should return an error if the specified user is not logged in', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?

				db.logout 'kayarr', asyncCatch(done) (err) ->
					expect(err).to.exist
					err.message.should.equal "Username 'kayarr' is not logged in"
					err.should.have.property 'code', 'not-logged-in'

					done()

	describe '.isRegistered()', ->
		it 'should return true if the user name exists', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?

				db.isRegistered 'kayarr', asyncCatch(done) (err, registered) ->
					expect(err).to.not.exist
					expect(registered).to.exist
					registered.should.be.true

					done()

		it 'should return false if the user name does not exist', (done) ->
			db.isRegistered 'kayarr', asyncCatch(done) (err, registered) ->
				expect(err).to.not.exist
				expect(registered).to.exist
				registered.should.be.false

				done()

	describe '.isLoggedIn()', ->
		it 'should return false if the user is not logged in', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?

				db.isLoggedIn 'kayarr', asyncCatch(done) (err, loggedIn) ->
					expect(err).to.not.exist
					expect(loggedIn).to.exist
					loggedIn.should.be.false

					done()

		it 'should return true if the user is logged in', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				return done err if err?

				db.login 'kayarr', 'boat', (err, user) ->
					return done err if err?

					db.isLoggedIn 'kayarr', asyncCatch(done) (err, loggedIn) ->
						expect(err).to.not.exist
						expect(loggedIn).to.exist
						loggedIn.should.be.true

						done()

		it 'should return an error if the user does not exist', (done) ->
			db.isLoggedIn 'kayarr', asyncCatch(done) (err, loggedIn) ->
				expect(err).to.exist.and.be.instanceof Error
				err.code.should.equal 'invalid-username'
				err.message.should.equal "Username 'kayarr' does not exist"
				expect(loggedIn).to.not.exist

				done()