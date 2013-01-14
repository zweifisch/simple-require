should = chai.should()
mocha.setup 'bdd'

describe 'require', ->

	describe 'get', ->
		it 'should load script synchrously', ->
			lib1 = require 'lib/lib1'
			(typeof lib1.echo).should.equal 'function'
			lib1.echo('echo').should.equal 'echo'

		it 'should load script in loaded script', ->
			lib2 = require 'lib/lib2'
			(typeof lib2.echo2).should.equal 'function'
			lib2.echo2('echo').should.equal 'echo echo'

