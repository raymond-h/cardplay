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
		it 'should return an array of challenges for a given user name
			(both sent and received)'

		it 'should return an empty array if the given user name has no challenges'
		
	describe '.add()', ->
		it 'should add challenges with the given sender and receiver user names'