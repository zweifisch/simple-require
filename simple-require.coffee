
require = (path)->
	unless path of require.required
		window.exports = {}
		window.module = window
		injectJS "#{path}.js"
		require.required[path] = window.exports
		delete window.exports
		delete window.module
	require.required[path]

require.required = {}

getXHR = ->
	if window.XMLHttpRequest
		ret = new XMLHttpRequest
	else
		try
			ret = new ActiveXObject 'Msxml2.XMLHTTP'
		catch e
			ret = new ActiveXObject 'Microsoft.XMLHTTP'
	ret

injectJS = (url)->
	xhr = getXHR()
	xhr.open 'GET', url, no
	xhr.send ''
	script = document.createElement 'script'
	script.type = 'text/javascript'
	script.text = xhr.responseText
	[head] = document.getElementsByTagName 'head'
	head.appendChild script

window.require = require
