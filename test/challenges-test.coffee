chai = require 'chai'

{expect} = chai
chai.should()

Datastore = require 'nedb'

describe 'ChallengeStorage', ->
	ChallengeStorage = require '../src/challenges'
	db = null

	before ->
		challengeDb = new Datastore()
		db = new ChallengeStorage challengeDb

	describe '.getForUser()', ->