required = {}


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


getEntryScript = ->
	[_...,script] = document.getElementsByTagName 'script'
	script.getAttribute 'data-main'


entryScript = getEntryScript()
if entryScript
	directRequire entryScript
