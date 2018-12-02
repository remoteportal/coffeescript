###
A - Array Functions					*** PROJECT AGNOSTIC ***


WHAT: Node module


DESCRIPTION



FEATURES
-


NOTES
-


TODOs
-


KNOWN BUGS:
-
###






trace = require './trace'



if !Array.isArray
	Array.isArray = (arg) -> Object::toString.call(arg) is '[object Array]'



arraysEqual = (a, b) ->
	if a == b
		return true
	if a == null or b == null
		return false
	if a.length != b.length
		return false

	#TODO: If you care about the order of the elements inside the array, you should sort both arrays here.

	i = 0
	while i < a.length
		if a[i] != b[i]
			return false
		++i

	true


module.exports =
#if ut
	s_ut: ->
		UT = require './ut'

		(new (class A_UT extends UT
			run: ->
				@t "arraysEqual", (ut) ->
					@assert arraysEqual [1,2,3], [1,2,3]
		)).run()
#endif




	arraysEqual: arraysEqual