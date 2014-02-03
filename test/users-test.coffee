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
		db.db.remove {}, done

	after (done) ->
		db.close()
		rimraf 'test-tmp', done

	describe '.register()', ->
		it 'should add users with valid username and password', (done) ->
			Q.fcall -> Q.ninvoke db, 'register', 'kayarr', 'boat'

			.then (user) ->
				expect(user).to.have.property('username').that.equals 'kayarr'
				expect(user).to.have.property('password').that.equals 'boat'

			.nodeify done

		it 'should return an error if given an invalid username'

	describe '.login()', ->
		it 'should mark user as logged in and return the user if username and password are correct'

		it 'should return an error and no user if the username does not exist or the password is wrong'