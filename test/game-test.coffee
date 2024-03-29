chai = require 'chai'
{asyncCatch} = require './common'

{expect} = chai
chai.should()

describe 'Game logic', ->
	{Session, Player, Card, Field, Health} = require '../src/game'
	{CardManager} = require '../src/card-manager'
	testCard = cardManager = null

	before ->
		cardManager = new CardManager
		testCard = cardManager.addCard 'unit',
			id: 'se.kayarr.tester_of_worlds'
			
			name: "Tester of Worlds"

			desc: "On entry, heals user 20 HP."

			flavor: "
				His less destructive tendencies compared to his brethen
				made him a lot more popular among the townspeople.
			"

			maxHealth: 30

	describe 'Session', ->
		describe '.toJSON()', ->
			it 'should return a JSON representation of a session', ->
				session = new Session [
					new Player 'kayarr',
						field: new Field
						health: new Health 500
						hand: [], deck: [testCard.newInstance()], discard: []

					new Player 'master',
						field: new Field
						health: new Health 500
						hand: [], deck: [testCard.newInstance()], discard: []
				]

				expect( session.toJSON() ).to.exist.and.deep.equal {
					turn: 0, round: 1
					players: [
						{
							username: 'kayarr', deck: [{card: testCard.id}],
							hand: [], discard: [],
							health:
								current: 500
								max: 500

							field: {
								width: 6, height: 2
								field: [
									[ null, null, null, null, null, null ]
									[ null, null, null, null, null, null ]
								]
							}
						}
						{
							username: 'master', deck: [{card: testCard.id}],
							hand: [], discard: [],
							health:
								current: 500
								max: 500

							field: {
								width: 6, height: 2
								field: [
									[ null, null, null, null, null, null ]
									[ null, null, null, null, null, null ]
								]
							}
						}
					]
				}

		describe '.fromJSON()', ->
			it 'should construct a Session object from a JSON representation', ->
				json = {
					turn: 1, round: 9
					players: [
						{
							username: 'kayarr', deck: [{card: testCard.id}],
							hand: [], discard: [],
							health:
								current: 500
								max: 500

							field: {
								width: 6, height: 2
								field: [
									[ null, null, null, null, null, null ]
									[ null, null, null, null, null, null ]
								]
							}
						}
						{
							username: 'master', deck: [{card: testCard.id}],
							hand: [], discard: [],
							health:
								current: 500
								max: 500

							field: {
								width: 6, height: 2
								field: [
									[ null, null, null, null, null, null ]
									[ null, null, null, null, null, null ]
								]
							}
						}
					]
				}

				session = Session.fromJSON json, cardManager

				expect(session).to.exist.and.be.instanceof Session
				session.turn.should.equal 1
				session.round.should.equal 9

				session.players.should.have.length 2
				for player in session.players
					player.should.be.instanceof Player
					player.field.should.be.instanceof Field
					
					player.hand.should.be.empty
					player.discard.should.be.empty
					player.deck.should.be.length 1
					player.deck[0].card.should.be.instanceof Card

	describe 'Field', ->
		describe '.toJSON()', ->
			it 'should return a JSON representation of a Field instance', ->
				field = new Field

				serialized = field.toJSON()

				expected = {
					width: 6, height: 2
					field: [
						[ null, null, null, null, null, null ]
						[ null, null, null, null, null, null ]
					]
				}

				expect(serialized).to.deep.equal expected

		describe '.fromJSON()', ->
			it 'should return a Field instance from the given JSON', ->
				inst =
					card: 'se.kayarr.tester_of_worlds'
					health:
						current: 30
						max: 30

				json = {
					width: 6, height: 2
					field: [
						[ null, null, null, null, null, null ]
						[ null, inst, null, null, null, null ]
					]
				}

				field = Field.fromJSON json, cardManager

				field.width.should.equal 6
				field.height.should.equal 2

				field.field[1][1].should.have.property 'card', testCard
				field.field[1][1].health.should.be.instanceof Health

				for row, y in field.field
					for v, x in row
						expect(v).to.be.null if x isnt 1 and y isnt 1
				

	describe 'Player', ->
		describe '.toJSON()', ->
			it 'should return a JSON representation of a Player instance', ->
				playerParams =
					field: new Field
					health: new Health 500

					hand: []
					deck: []
					discard: []

				player = new Player 'kayarr', playerParams

				expected = {
					username: 'kayarr'
					deck: [], hand: [], discard: []
					health:
						current: 500
						max: 500

					field: {
						width: 6, height: 2
						field: [
							[ null, null, null, null, null, null ]
							[ null, null, null, null, null, null ]
						]
					}
				}

				serialized = player.toJSON()

				expect(serialized).to.deep.equal expected

		describe '.fromJSON()', ->
			it 'should return a Player instance from the given JSON', ->
				json = {
					username: 'kayarr'
					deck: [], hand: [], discard: []
					health:
						current: 500
						max: 500

					field: {
						width: 6, height: 2
						field: [
							[ null, null, null, null, null, null ]
							[ null, null, null, null, null, null ]
						]
					}
				}

				player = Player.fromJSON json, cardManager

				player.username.should.equal 'kayarr'
				player.deck.should.be.instanceof(Array).and.have.length 0
				player.hand.should.be.instanceof(Array).and.have.length 0
				player.discard.should.be.instanceof(Array).and.have.length 0
				player.field.should.be.instanceof Field

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