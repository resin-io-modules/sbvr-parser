_ = require('lodash')

expect = require('chai').expect

require('ometa-js')
SBVRParser = require('../sbvr-parser.ometajs').SBVRParser.createInstance()

lfSoFar = [ 'Model',
	[ 'Vocabulary', 'Default', [ 'Attributes' ] ]
]
seSoFar = ''

runExpectation = (describe, lf, expectation) ->
	switch lf[0]
		when 'Term'
			[type, text] = lf
		when 'FactType'
			type = 'Fact Type'
			text = _.map(lf[1...], (factTypePart) -> factTypePart[1]).join(' ')
	input = type + ': ' + text
	describe 'Parsing ' + input, ->
		try
			SBVRParser.reset()
			newLF = SBVRParser.matchAll(seSoFar + input, 'Process')
			if newLF.length == lfSoFar
				last = newLF[newLF.length - 1]
				attributes = last[last.length - 1]
				result = attributes[attributes.length - 1]
			else
				result = newLF[newLF.length - 1]
			lfSoFar = newLF
			seSoFar += input + '\n'
			switch lf[0]
				when 'Term', 'FactType'
					it 'should be a ' + type + ' "' + text + '"', ->
						expect(result).to.deep.equal(lf)
			expectation?(result)
		catch e
			if expectation?
				expectation(e)
			else
				throw e

module.exports = runExpectation.bind(null, describe)
module.exports.skip = runExpectation.bind(null, describe.skip)
module.exports.only = runExpectation.bind(null, describe.only)