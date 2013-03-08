required = {}
preset = require?.preset ? {}


joinPath = (parts...)->
	concat = (done,part)->
		done.concat part.split '/'
	notEmpty = (x)->
		x.length > 0 and x isnt '.'
	parent = (done,part)->
		if part is '..'
			done.pop()
		else
			done.push part
		done
	parts
		.reduce(concat,[])
		.filter(notEmpty)
		.reduce(parent, [])
		.join '/'


dirname = (path)->
	[tokens...,_] = path.split '/'
	joinPath tokens...


getXHR = ->
	if window.XMLHttpRequest
		ret = new XMLHttpRequest
	else
		try
			ret = new ActiveXObject 'Msxml2.XMLHTTP'
		catch e
			ret = new ActiveXObject 'Microsoft.XMLHTTP'
	ret


getSync = (url)->
	xhr = getXHR()
	xhr.open 'GET', url, no
	xhr.send ''
	xhr


injectJS = (content)->
	script = document.createElement 'script'
	script.type = 'text/javascript'
	script.text = content
	[head] = document.getElementsByTagName 'head'
	head.appendChild script

insertScript = (src,callback)->
	script = document.createElement 'script'
	script.type = 'text/javascript'
	script.src = src
	[head] = document.getElementsByTagName 'head'
	script.onreadystatechange = callback
	script.onload = callback
	head.appendChild script

insertScripts = (scripts,callback)->
	do next = ->
		script = scripts.shift()
		if script
			insertScript script,next
		else
			callback()

expose = (objects,block)->
	conflicts = {}
	for own name,object of objects
		if name of window
			conflicts[name] = window[name]
		window[name] = object
	block ->
		for own name of objects
			if name of conflicts
				window[name] = object
			else
				delete window[name]


getRequire = (currentPath)->
	(path)->
		path = joinPath currentPath,path
		unless path of required
			directRequire path
		required[path]


directRequire = (path)->
	exports = {}
	objects =
		require: getRequire dirname path
		exports: exports
		module:
			exports: exports

	if preset?[path]
		preset[path] objects.require,objects.exports,objects.module
		required[path] = objects.module.exports
		delete preset[path]
	else
		result = getSync "#{path}.js"
		if result.status isnt 200
			throw
				message: result.statusText
				code: result.status
		expose objects, (restore)->
			injectJS """
			(function(require,exports,module){
				#{result.responseText}
			})(require,exports,module)
			"""
			restore()
			required[path] = objects.module.exports


getOptions = ->
	[_...,script] = document.getElementsByTagName 'script'
	main: script.getAttribute 'data-main'
	shims: script.getAttribute 'data-shims'

options = getOptions()
	
entryScript  = require?.entryScript ? options.main

if options.shims
	result = getSync "#{options.shims}"
	if result.status isnt 200
		throw
			message: result.statusText
			code: result.status
	else
		srcs = ("#{joinPath dirname(options.shims),src}.js" for src in result.responseText.split "\n" when src isnt '' and src[0] isnt '#')
		insertScripts srcs,->
			directRequire entryScript
else
	directRequire entryScript
