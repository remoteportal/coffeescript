###
N - Number Functions					*** PROJECT AGNOSTIC ***


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



WORD = (n) ->
	if n is null
		""
	else if n < 11
		C = require './C'
		C.A_NUMBERS_ENGLISH[n]
	else
		R.V.COMMAIZE n




module.exports =
#	ASCIIHEX: (n) ->
##if n <= -3 or n >= 18
##	throw n
#		if n > 15
#			C.A_I_TO_LC_ASCII_HEX[15]
#		else if n < 0
#			C.A_I_TO_LC_ASCII_HEX[0]
#		else
#			C.A_I_TO_LC_ASCII_HEX[Math.round n]


	CONSTRAIN: (min, n, max) -> Math.max min, Math.min(n, max)


	GUIDNew: ->		# uuidv4
		'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
			r = Math.random() * 16 | 0
			v = if c == 'x' then r else r & 0x3 | 0x8
			v.toString 16

			
	PLURAL: (n) -> if n is 0 or n >= 2 then "s" else ""


	ROUND: (f, decCnt) -> Math.round(f*Math.pow 10, decCnt) / Math.pow(10,decCnt)						#SO: 16319855


# N.RND -> 0,1
# N.RND y -> 0-(y-1)
# N.RND x,y -> x-y
	RND: (min = 1, max) ->
		unless max
			max = min
			min = 0
		Math.floor Math.random() * (max-min+1) + min


	SIGN: (n) ->
		if isNaN n
			NAN
		else if n is 0
			0
		else if n > 0
			1
		else
			-1


	PERIOD: (n) ->
		if n > 0
			s = ""
			for j in [1..n]
				s += "."
			s
		else
			R.AT n is 0
			""


	WORD: WORD


	ZEROPAD: (n, len) -> ("000000000" + n).slice -len


#if ut
	s_ut: ->
		UT = require './ut'

		(new (class N_UT extends UT
			run: ->
				@t "WORD", (ut) ->
#					@log "WORD: #{WORD 5}"
					@eq WORD(5), "five"
		)).run()
#endif