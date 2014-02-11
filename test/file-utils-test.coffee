chai = require 'chai'

{expect} = chai
chai.should()

fs = require 'fs'
rimraf = require 'rimraf'
Q = require 'q'
_ = require 'underscore'
path = require 'path'

Q.longStackSupport = yes

describe 'File utils', ->

	fileUtils = require '../src/file-utils'

	before (done) ->
		[writeFile, mkdir] = [Q.nbind(fs.writeFile, fs), Q.nbind(fs.mkdir, fs)]

		mkdir 'walk-test'
			.then -> Q.all [
				writeFile 'walk-test/banana.txt', ''
				writeFile 'walk-test/yeah.boat', ''

				mkdir 'walk-test/wat'
					.then -> Q.all [
						writeFile 'walk-test/wat/wooot.txt', ''
						writeFile 'walk-test/wat/excellent.coffee', ''
					]
			]
		.nodeify done

	after (done) ->
		rimraf 'walk-test', done

	describe '.walkFolder()', ->
		it 'should call a done callback when it has finished walking', (done) ->
			fileUtils.walkFolder 'walk-test', (->), done

		it 'should call a callback for every file it finds in a folder recursively', (done) ->
			expectedFiles = (path.resolve file for file in [
					'./walk-test/banana.txt'
					'./walk-test/yeah.boat'
					'./walk-test/wat/wooot.txt'
					'./walk-test/wat/excellent.coffee'
				])
			files = []

			fileUtils.walkFolder 'walk-test', (err, file) ->
				files.push file
				doneAll()

			doneAll = _.after 4, ->
				try
					files.should.include f for f in expectedFiles
					done()
				catch e then done e