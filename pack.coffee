#!/usr/bin/env coffee
fs = require 'fs'
path = require 'path'
program = require 'commander'
uglifyjs = require 'uglify-js'


program
	.version('0.0.1')
	.option('--concat-scripts <file>', 'concat scripts list in <file>')
	.option('--list-dependency <file>', 'list dependencies of a script')
	.option('--build <file>', 'concat the script with all it\'s dependencies')
	.option('--minify', 'minify the concated script using uglifyjs')
	.parse process.argv


parseFileList = (filename)->
	basedir = path.dirname filename
	scripts = fs.readFileSync(filename, 'utf-8')
		.split("\n")
		.filter((x)-> x.length > 0 and x[0] isnt '#')
		.map (x)-> [x, path.join basedir, "#{x}.js"]


concatScripts = (scriptFiles,entry)->
	required = {}
	scripts = scriptFiles.map ([key,filename])->
		unless key of required
			script = fs.readFileSync filename, 'utf-8'
			"""
			require.preset["#{key}"] = function(require,exports,module){
				#{script}
			};
			"""
	
	simpleRequire = fs.readFileSync path.join (path.dirname process.argv[1]), 'simple-require.js'
	"""
	(function(){
		require = {
			preset:{},
			entryScript: "#{entry[0]}"
		};
		#{scripts.join "\n"}
		#{simpleRequire}
	})()
	"""


scanForRequire = (content)->
	result = /\s*require\s*\(\s*['"]([a-zA-Z0-9._-])['"]\s*\)/.match content


getDependencyTree = (filename)->


minify = (input)->
	minified = uglifyjs.minify input, fromString:yes
	minified.code


if program.concatScripts
	configFile = program.concatScripts
	unless fs.existsSync configFile
		console.log "#{configFile} not found"
		process.exit 1
	scriptFiles = parseFileList program.concatScripts
	output = concatScripts scriptFiles, scriptFiles[0]
	if program.minify
		output = minify output
	process.stdout.write output
