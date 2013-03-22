#!/usr/bin/env coffee
fs = require 'fs'
path = require 'path'
program = require 'commander'
uglifyjs = require 'uglify-js'


parseFileList = (filename)->
	basedir = path.dirname filename
	scripts = fs.readFileSync(filename, 'utf-8')
		.split("\n")
		.filter((x)-> x.length > 0 and x[0] isnt '#')
		.map (x)-> [x, path.join basedir, "#{x}.js"]


getSimpleRequire = ->
	fs.readFileSync path.join((path.dirname __filename), 'simple-require.js'),'utf-8'


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
	"""
	(function(){
		require = {
			preset:{},
			entryScript: "#{entry[0]}"
		};
		#{scripts.join "\n"}
		#{getSimpleRequire()}
	})()
	"""


scanForRequire = (content)->
	result = content.match ///
		require\s*            # require
		\(\s*['"]             # ('
			([a-zA-Z0-9./_-]+) # ./path/to.js
		['"]\s*\)             # ')
		///g
	if result?
		result.map (statement)->
			statement.match(/['"]([a-zA-Z0-9./_-]+)['"]/)[1]
	else
		[]


getDependencies = (filename, dict={}, requiredBy=null)->
	unless fs.existsSync filename
		if requiredBy?
			exit "#{filename} not exists, required by #{requiredBy}"
		else
			exit "#{filename} not exists"
	requires = scanForRequire fs.readFileSync filename, 'utf-8'
	requires = requires.map (r)-> path.join path.dirname(filename), "#{r}.js"
	dict[filename] = requires
	for r in requires
		getDependencies r, dict, filename unless r of dict
	dict


getDependencyTree = (dict,keys)->
	ret = {}
	keys ?= Object.keys dict
	for file in keys
		ret[file] = getDependencyTree dict,dict[file]
	ret


flatten = (dict)->
	ret = Object.keys dict
	for k in ret
		for _k in flatten dict[k]
			ret.push _k unless _k in ret
	ret


prettyPrint = (data,indent=0)->
	whitespaces = [0..indent].map((x)->' ').join ''
	if Array.isArray data
		prettyPrint item,indent for item in data
	else if typeof data is 'string'
		console.log "#{whitespaces}#{data}"
	else
		for k,v of data
			console.log "#{whitespaces}#{k}"
			prettyPrint v, indent + 3


minify = (input)->
	minified = uglifyjs.minify input, fromString:yes
	minified.code


exit = (message, code=1)->
	console.log message
	process.exit code


main = ->
	program
		.version('0.0.7')
		.option('-c, --concat-scripts <file>', 'concat scripts list in <file>')
		.option('-l, --list-dependency <file>', 'list dependencies of a script')
		.option('--json', 'output as json when listing dependencies')
		.option('--flat', 'output dependencies as a flat list')
		.option('-b, --build <file>', 'concat the script with all it\'s dependencies')
		.option('-m, --minify', 'minify the output using uglifyjs')
		.option('--shims <file>', 'specify a list of shims to be included')
		.option('--get-simple-require', 'write simple-require.js to stdout')
		.parse process.argv

	output = ''
	if program.listDependency
		dependencies = getDependencies program.listDependency
		output = getDependencyTree dependencies, [program.listDependency]

		if program.flat
			output = flatten output

		if program.json
			console.log JSON.stringify output, null, 3
		else
			prettyPrint output
		process.exit 0


	if program.concatScripts
		configFile = program.concatScripts
		unless fs.existsSync configFile
			exit "#{configFile} not found"
		scriptFiles = parseFileList program.concatScripts
		output = concatScripts scriptFiles, scriptFiles[0]


	if program.build
		dependencies = flatten getDependencyTree getDependencies program.build
		dependencies = dependencies.map (x)-> [x[0...-3],x]
		output = concatScripts dependencies, dependencies[0]

	if program.getSimpleRequire
		output = getSimpleRequire()

	if program.shims
		shims = parseFileList(program.shims).map ([_,path])->
			fs.readFileSync path,'utf-8'
		output = "#{shims.join ';'};#{output}"

	if program.minify
		output = minify output

	if output
		process.stdout.write output

main()
