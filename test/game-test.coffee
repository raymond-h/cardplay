chai = require 'chai'

{expect} = chai
chai.should()

describe 'Game logic', ->
	{Session, Player, Card, Field, Health} = require '../src/game'

	describe 'Session', ->
		describe '.toJSON()', ->
			it.only 'should return a JSON representation of a session', ->
				session = new Session [
					new Player 'kayarr'
					new Player 'master'
				]

				expect( session.toJSON() ).to.exist.and.deep.equal {
					turn: 0
					round: 1
					players: [
						{
							username: 'kayarr', deck: [], hand: [],
							discard: [], field: null
						}
						{
							username: 'master', deck: [], hand: [],
							discard: [], field: null
						}
					]
				}

	describe 'Health', ->
		describe '.multiplier', ->
			it 'should return the multiplier of the health', ->
				health = new Health 60
				health.multiplier.should.equal 1

				health.current = 30
				health.multiplier.should.equal 0.5

				health.current = 0
				health.multiplier.should.equal 0

			it 'should change current health when written to', ->
				health = new Health 60

				health.multiplier = 1
				health.current.should.equal = 60

				health.multiplier = 0.5
				health.current.should.equal = 30

				health.multiplier = 0
				health.current.should.equal = 0

		describe '.atMin', ->
			it 'should return true if health is 0 or less', ->
				health = new Health 60

				health.current = 0
				health.atMin.should.equal true

				health.current = -30
				health.atMin.should.equal true

			it 'should return false if health is more than 0', ->
				health = new Health 60
				health.atMin.should.equal false

				health.current = 30
				health.atMin.should.equal false

		describe '.atMax', ->
			it 'should return true if health is max or more', ->
				health = new Health 60
				health.atMax.should.equal true

				health.current = 90
				health.atMax.should.equal true

			it 'should return false if health is less than max', ->
				health = new Health 60

				health.current = 30
				health.atMax.should.equal false

				health.current = 0
				health.atMax.should.equal false