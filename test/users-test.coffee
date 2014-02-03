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
		db.clear done

	after (done) ->
		# close db
		rimraf 'test-tmp', done

	describe '.register()', ->
		it 'should add users with valid username and password', (done) ->
			Q.fcall -> Q.ninvoke db, 'register', 'kayarr', 'boat'

			.then -> Q.ninvoke db, 'get', 'kayarr'

			.then (userdata) ->
				expect(userdata).to.have.property('username').that.equals 'kayarr'
				expect(userdata).to.have.property('password').that.equals 'boat'

			.nodeify done

		it 'should reject users with invalid username'

	describe '.login()', ->
		it 'should return true if the username exists and the password is correct'

		it 'should signal if the username does not exist or the password is wrong'