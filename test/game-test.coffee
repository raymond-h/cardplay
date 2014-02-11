chai = require 'chai'

{expect} = chai
chai.should()

describe 'Game logic', ->
	{Session, Player, Card, Field, Health} = require '../src/game'

	describe 'Health', ->
		describe '.multiplier', ->
			it 'should return the multiplier of the health', ->
				health = new Health 60
				health.multiplier.should.equal 1

				health.current = 30
				health.multiplier.should.equal 0.5

				health.current = 15
				health.multiplier.should.equal 0.25

				health.current = 0
				health.multiplier.should.equal 0

			it 'should change current health when written to', ->
				health = new Health 60

				health.multiplier = 1
				health.current.should.equal = 60

				health.multiplier = 0.5
				health.current.should.equal = 30

				health.multiplier = 0.25
				health.current.should.equal = 15

				health.multiplier = 0
				health.current.should.equal = 0