###
V - Value functions					*** PROJECT AGNOSTIC ***


WHAT: Node module


DESCRIPTION



FEATURES
-


NOTES
- "A primitive (primitive value, primitive data type) is data that is not an object and has no methods. In JavaScript, there are 6 primitive data types: string, number, boolean, null, undefined, symbol"


TODOs
- throw error if find new datatype


KNOWN BUGS:
-
###



trace = require './trace'


# [object Function]
RE_ISOLATE_TYPE = /\[object ([^\]]*)\]/













COMPARE_REPORT = (v0, v1) ->		#H: string-oriented or value (V)-oriented?
	buf = ''

	if s0 is s1
		buf = "values are the same"
	else
		bStrings = true
		
		for v in [v0, v1]
			bStrings = false		unless IS v

		if bStrings
			S = require './S'
			buf = S.COMPARE_REPORT v0, v1
		else
			#TODO: see if integer and float.... negative/positive: EXPLAIN difference between the values
			buf = "values are different"		#HACK
	buf



# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects
DUMP = (v) ->
	try
#		type = Object::toString.call v
#		# [object Function]
#		re = /\[object ([^\]]*)\]/
#		match = re.exec type
#		if match
#			console.log "match=#{match[1]}"
#		else
#			console.error "DUMP: unable to isolate type from: \"#{type}\""
#			process.exit 1

		if v?
			Ty = Type v

#			console.log "V.DUMP: DEBUG: {v} ARRAY=#{Array.isArray v} TYPEOF=#{typeof v} TYPE=#{Ty} JSON=#{JSON.stringify v}"

			switch Ty
				when "Boolean", "boolean", "Number", "number"
					v
				when "function"
					"FN"
#					v
				when "Promise"
					#TODO: dump attributes
					"#{v} <Promise>"
				when "Response"
					O = require './O'
#					O.LOG v		#INFINITE_LOOP
					#HACK
#					for k,v of v
#						O.LOG v
					"RESPONSE: #{JSON.stringify v}"
				when "String", "string"
					if v.length is 0
						"\"\""
					else
						v
				when "Uint8Array"
#					"#{v} <#{Ty}> #{JSON.stringify v}"
					"Uint8Array: len=#{v.length}: buffer=#{v}: JSON=#{JSON.stringify v}"
				else
					"#{v} <#{Ty}> UNKNOWN"
		else
#			console.log "V.DUMP: DEBUG: {v} ARRAY=#{Array.isArray v} TYPEOF=#{typeof v} TYPE=#{Ty} JSON=#{JSON.stringify v}"
#			"null or undefined"
			"null"		#H #WARNING
	catch ex
		console.error "V.DUMP exception: #{ex}"
		process.exit 1



EQ = (a, opts = {}) ->
	bEQ = true

#	@logSilent "inside eq: a.length=#{a.length}"

	#		@log "ut: bRunToCompletion=#{@bRunToCompletion}"

	if a.length >= 2
#		@logSilent "a passed: a.length=#{a.length}"

		# both undefined?
		#TODO: check all args
		if !(a[0]?) and !(a[1]?)
#			@logSilent "both undefined"
		else
			if opts.bTypes
#				console.log "---CHECK TYPES---"

				_ = type a[0]
				#			process.exit 1
				for i in [0..a.length-1]
		#				@log "arg#{i}: #{PAIR a[i]} #{typeof a[i]}"
		#				@log "arg#{i}: #{PAIR a[i]} #{typeof a[i]} --> #{S.DUMP type(a[i]), true}"
		#				@log "#{_}-#{type a[i]}"
					unless _ is type a[i]
						bEQ = false
				#					console.log "TTTTTTTTTT"
				#			console.log "aaa"

				unless bEQ
					s = "@eq types violation:\n"
					for i in [0..a.length-1]
						s += "> arg#{i}: #{type a[i]}\n"
					#				@log "ut2: bRunToCompletion=#{@bRunToCompletion}"
#					@logError s
					console.log s


			if bEQ
#				console.log "---CHECK VALUES---"
				bEQ = true
#				_ = a[0]
#				for i in [0..a.length-1]
#					console.log "arg#{i}: #{PAIR a[i]} #{typeof a[i]}"
#
#					#WARNING: old code used to sometime hang node; it was very bizarre
#					#NOTE #REVELATION: "peter" NOT-EQUAL-TO new String "peter" so force to string first!!!!!!!!!!!!!
#					unless ""+_ is ""+a[i]
#						bEQ = false
				# console.log "i=#{i}: #{_}-#{a[i]}"
				if ""+a[0] isnt ""+a[1]
					bEQ = false

				unless bEQ
					LOG_DELTA a[0], a[1]

	bEQ


KV = (k, v, bReverse) ->
	O = require './O'
	if bReverse
		"#{k} = <#{Type v}> #{O.duck v}"
	else
		"#{k} = #{O.duck v} <#{Type v}>"		#TODO: distinquish between primative and non-primative



LOG_DELTA = (v1, v2) ->
	O = require './O'
	S = require './S'

	t1 = typeof v1
	t2 = typeof v2

	a = [v1, v2]	#HACK

	if t1 is t2 is "string"
		s = "@eq values violation:\n"
		s += "> arg#{a[0]}: #{PAIR a[0]} DUMP: #{S.DUMP a[0], undefined, true}\n"
		s += "> arg#{a[1]}: #{PAIR a[1]} DUMP: #{S.DUMP a[1], undefined, true}\n"
		#					@logError s
		console.log s
	else
		console.log "LOG_DELTA: not strings"
		O.LOG v1
		O.LOG v2



#NOTE: tabs look wrong but are actually right
LOG_MULTI = (v, pn) ->
	console.log "\n\n\n\n\n\n\n\n\n\n"
	console.log "O.LOG:"
	console.log "JSON:			#{JSON.stringify v}"
	console.log "JSON len:		#{JSON.stringify(v).length}"
	console.log "isArray:		#{Array.isArray v}"
	console.log "typeOf:			#{typeof v}"
	console.log "type:			#{Object::toString.call v}"

	if v instanceof Uint8Array
		console.log "Uint8Array"
	else
		try
#			console.log "as string:		#{""+v}"		# argument should be a Buffer
			console.log "as string:		#{v.toString()}"
			console.log "as string len:		#{(""+v).length}"
			console.log "==============================================="
			try
			"#{if pn then "#{pn}=" else ""}#{v} ARRAY=#{Array.isArray v} TYPEOF=#{typeof v} TYPE=#{Object::toString.call v} JSON=#{JSON.stringify v}"
		catch ex
			console.log "LOG_MULTI EXCEPTION: *****************************"
			console.log ex
#			process.exit 1



LOG_SINGLE = (v, pn) ->
	console.log SINGLE v, pn



NOT_STRING = (v) ->
	if type(v) is "string"
#		console.log "ooo=#{type v}"
		if v.length
			v
		else
			"\"\""
	else
		PAIR v



PAIR = (v) -> "#{v} <#{Type v}>"		#TODO: distinquish between primative and non-primative



# "peter"				=>
# new String "peter"	=>
#typeMap = {}
#TYPE = (v) ->
##	if _=typeMap[v]
##		_
##	else
#
#	type = Object::toString.call v
#
#	match = RE_ISOLATE_TYPE.exec type
#	if match and match.length >= 2
##		console.log "match=#{match[1]}"
#
## primative vs. non-primative types
#		if typeof v is "object"
#			type = match[1]
#		else
#			type = typeof v
#
#		console.log "#{v} => #{type}"
##			typeMap[v] = type
#	else
#		util.abort "V.TYPE: Unable to isolate type substring from: \"#{type}\""
#TYPE = (v) ->		#DEP
##	console.log "TYPE: v=#{v}"
##	console.log "TYPE: typeof v=#{typeof v}"
##	console.log "TYPE: call v=#{Object::toString.call v}"
#
#
#
#	# primative vs. non-primative types
#	if typeof v is "object"
#		type = Object::toString.call v
#
#		match = RE_ISOLATE_TYPE.exec type
#		if match and match.length >= 2
##			console.log "match=#{match[1]}"
#			typeMap[v] = type = match[1]		#WRONG: need REAL ES6 Map
#			console.log "#{v} => #{type} (call)"
#		else
#			util.abort "V.TYPE: Unable to isolate type substring from: \"#{type}\""
#	else
#		type = typeof v
#		console.log "#{v} => #{type} (typeof)"
#
#	type



SINGLE = (v,pn) ->
	try
		"#{if pn then "#{pn}=" else ""}#{v} ARRAY=#{Array.isArray v} TYPEOF=#{typeof v} TYPE=#{Object::toString.call v} JSON=#{JSON.stringify v}"
	catch ex
		console.log "SINGLE EXCEPTION: *****************************"
		console.log ex
		LOG_MULTI v
#		process.exit 1



# "peter"				=> string
# new String "peter"	=> String		Capitalized!
#THROWS
Type = (v) ->
	# primative vs. non-primative types
	if typeof v is "object"
		t = Object::toString.call v

		match = RE_ISOLATE_TYPE.exec t
		if match and match.length >= 2
#			console.log "match=#{match[1]}"
			t = match[1]		#WRONG: need REAL ES6 Map
#			console.log "#{v} => #{t} (call)"
		else
			util.abort "V.Type: Unable to isolate type substring from: \"#{t}\""
	else
		t = typeof v
#		console.log "#{v} => #{t} (typeof)"

	t


# "peter"				=> string
# new String "peter"	=> string		lower-case!
type = (v) ->
# 	primative vs. non-primative types
	if typeof v is "object"
		t = Object::toString.call v

		match = RE_ISOLATE_TYPE.exec t
		if match and match.length >= 2
#			console.log "match=#{match[1]}"
			t = match[1].toLowerCase()

#			console.log "#{v} => #{t} (call)"
		else
			util.abort "V.type: Unable to isolate type substring from: \"#{t}\""
	else
		t = typeof v
#		console.log "#{v} => #{t} (typeof)"

	t




module.exports =
	COMPARE_REPORT: COMPARE_REPORT
	DUMP: DUMP
#	EQ: (v1, v2) -> console.log "COMP: #{v1} vs. #{v2} (#{typeof v1}) vs (#{typeof v2}) #{if v1 is v2 then "YES-MATCH" else "NO-MATCH"}"	#USED?
	EQ: EQ
	KV: KV
	LOG_DELTA: LOG_DELTA
	LOG_MULTI: LOG_MULTI
	LOG_SINGLE: LOG_SINGLE
	NOT_STRING: NOT_STRING
	PAIR: PAIR
	SINGLE: SINGLE
	TYPE: Type		#DEP
	Type: Type
	type: type
#if ut
	s_ut: ->
		UT = require './ut'

		class VU_UT extends UT
			run: ->
				@t "DUMP", ->
					if trace.UT_TEST_LOG_ENABLED
						@log DUMP "literal string"
						@log DUMP new String "string object"
						@log DUMP a:"a"
						@log DUMP 45
						@log DUMP true
						@log DUMP undefined
						@log DUMP null
#						@log DUMP VUT
						@log DUMP ->
						@log DUMP []
						@log DUMP new Date()
						@log DUMP new Uint16Array()
				@t "EQ" ,->
					@log "EQ"
					@assert EQ [1, 1]
					#			@assert EQ [1, 2]
					@assert EQ ["aaa", "aaa"]
				#			@assert EQ ["aaa", "bbb"]
				@t "Type", ->
					@eq Type(45), "number"
					@eq Type(new Number 45), "Number"
					@eq Type(new Number(45)), "Number"
					@eq Type("literal string"), "string"
					@eq Type(new String "string class"), "String"
					@eq Type(null), "Null"
					@eq Type(undefined), "undefined"
					@eq Type(->), "function"
					@eq Type(new Date()), "Date"
					@eq Type(new Uint32Array()), "Uint32Array"
					@eq Type([]), "Array"
					@eq Type(true), "boolean"
					@eq Type(new Boolean(false)), "Boolean"
				@t "type", ->
					@eq type(45), "number"
					@eq type(new Number 45), "number"
					@eq type(new Number(45)), "number"
					@eq type("literal string"), "string"
					@eq type(new String "string class"), "string"
					@eq type(null), "null"
					@eq type(undefined), "undefined"
					@eq type(->), "function"
					@eq type(new Date()), "date"
					@eq type(new Uint32Array()), "uint32array"
					@eq type([]), "array"
					@eq type(true), "boolean"
					@eq type(new Boolean(false)), "boolean"
				@t "Uint8Array NOT", ->
		#			json = '{"type":"Buffer","data":[123,34,99,34,58,34,99,32,118,97,108,117,101,34,125]}'
		#			o = JSON.parse json
		#			LOG_MULTI o
		#			LEARN: hoping would be type=Uint8Array but it's not


					if trace.HUMAN
						uint8 = new Uint8Array 2
						uint8[0] = 42
						console.log uint8[0]
						# 42
						console.log uint8.length
						# 2
						console.log uint8.BYTES_PER_ELEMENT
						# 1
						LOG_MULTI uint8


						@log "GGGGGGGGGGG=#{DUMP uint8}"
		new VU_UT().run()
#endif