chai = require 'chai'

{expect} = chai
chai.should()

describe 'Send utils', ->
	sendUtils = require '../src/send-utils'

	describe '.sendableJson()', ->
		it 'should take non-string values and convert into JSON', ->
			obj = { boat: 'yoo', hi: 9784, oh: ['woah', [99], 45, {}] }

			sendUtils.sendableJson(obj, '\r\n').should.equal '49\r\n{"boat":"yoo","hi":9784,"oh":["woah",[99],45,{}]}'

		it 'should pass string values directly as JSON', ->
			sendUtils.sendableJson('["boat","yoo"]', '\r\n').should.equal '14\r\n["boat","yoo"]'
			sendUtils.sendableJson('yes, really', '\r\n').should.equal '11\r\nyes, really'

	describe '.parseSendableJson()', ->
		it 'should parse a message into a proper object', ->
			message = '49\r\n{"boat":"yoo","hi":9784,"oh":["woah",[99],45,{}]}'

			[object, startOfNext] = sendUtils.parseSendableJson(message, '\r\n')
			object.should.deep.equal { boat: 'yoo', hi: 9784, oh: ['woah', [99], 45, {}] }
			startOfNext.should.equal 2+2+49