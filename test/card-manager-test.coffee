chai = require 'chai'
{asyncCatch} = require './common'

{expect} = chai
chai.should()

fs = require 'fs'
rimraf = require 'rimraf'

describe 'CardManager', ->
	CardManager = require '../src/card-manager'

	beforeEach ->
		fs.mkdirSync './test-tmp'

	afterEach (done) ->
		rimraf './test-tmp', done

	describe '.getJsSource()', ->
		it 'should return the contents of .js files directly', ->
			code = """
				ready(function(addCard) {
					addCard('unit', {
						id: 'hello',
						name: 'Hello-er of Doom!'
					});
				})
			"""

			fs.writeFileSync './test-tmp/hello.js', code

			source = CardManager.getJsSource './test-tmp/hello.js'

			source.should.equal code

		it 'should automatically compile .coffee files to Javascript and return that', ->
			code = """
				ready (addCard) ->
					addCard 'unit',
						id: 'hello'
						name: 'Hello-er of Doom!'
			"""

			expected = """
				(function() {
				  ready(function(addCard) {
				    return addCard('unit', {
				      id: 'hello',
				      name: 'Hello-er of Doom!'
				    });
				  });

				}).call(this);\n
			"""

			fs.writeFileSync './test-tmp/hello.coffee', code

			source = CardManager.getJsSource './test-tmp/hello.coffee'

			source.should.equal expected

		it 'should throw an error if given faulty Coffeescript', ->
			code = """
				ready (addCard) ->
					addCard,
						95: ggg
			"""

			fs.writeFileSync './test-tmp/hello.coffee', code

			expect( -> CardManager.getJsSource './test-tmp/hello.coffee' ).to.throw Error