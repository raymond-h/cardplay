chai = require 'chai'

{expect} = chai
chai.should()

describe 'ChallengeStorage', ->
	ChallengeStorage = require '../src/challenges'
	db = null

	before ->
		db = new ChallengeStorage('test-tmp/user-test.db')

	after (done) ->
		rimraf 'test-tmp', done

	describe '.getForUser()', ->