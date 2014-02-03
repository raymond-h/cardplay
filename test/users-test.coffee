chai = require 'chai'

{expect} = chai
chai.should()

fs = require 'fs'
Q = require 'q'
rimraf = require 'rimraf'

describe 'UserStorage', ->
	UserStorage = require '../src/users'
	db = null

	before ->
		db = new UserStorage('test-tmp/user-test.db')

	beforeEach (done) ->
		db.loggedInUsers = []
		db.clear done

	after (done) ->
		db.close()
		rimraf 'test-tmp', done

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
				err.message.should.equal "Invalid username 'U#(YTU =¤WITWYHUOcrazy'"
				expect(user).to.not.exist
				done()

		it 'should return an error if a username is already taken'

	describe '.login()', ->
		it 'should mark user as logged in if username and password are correct', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				if err? then throw err

				db.login 'kayarr', 'boat', (err, user) ->
					expect(err).to.not.exist
					expect(user).to.exist

					user.should.deep.equal { username: 'kayarr', password: 'boat' }

					db.loggedInUsers.should.contain 'kayarr'

					done()

		it 'should return an error if the password is wrong', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				if err? then throw err

				db.login 'kayarr', 'woah', (err, user) ->
					expect(err).to.exist.and.be.instanceof Error
					err.message.should.equal 'Invalid username or password'
					expect(user).to.not.exist

					db.loggedInUsers.should.not.contain 'kayarr'

					done()

		it 'should return an error if given a nonexistant user', (done) ->
			db.register 'kayarr', 'boat', (err, user) ->
				if err? then throw err

				db.login 'woot', 'boat', (err, user) ->
					expect(err).to.exist.and.be.instanceof Error
					err.message.should.equal 'Invalid username or password'
					expect(user).to.not.exist

					db.loggedInUsers.should.not.contain ['kayarr', 'woot']

					done()