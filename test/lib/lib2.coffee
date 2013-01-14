
{echo} = require 'lib/lib1'

exports.echo2 = (msg)->
	"#{echo msg} #{echo msg}"

exports.version = 'v0.0.3'
