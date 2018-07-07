###
O - Object Functions					*** PROJECT AGNOSTIC ***


WHAT: Node module


DESCRIPTION



FEATURES
-


NOTES
-


TODOs
- LOG: pass explicit opts
- LOG: maxDepth option
- LOG: look at arguments.length to see if any passed parameters are undefined or null and PUT IN ALL CAPS!
- LOG: Object.getOwnProperty to show hidden (non-enumerable) properties
- #	log "#{["1st","2nd","3rd","4th","5th","6th","7th","8th","9th","next","next","next"][objectFoundNbr++]} OBJ PASSED", v, 0
- O.DUMP with opts map
- NEXT: abort if legs repeated in path


KNOWN BUGS:
-
###






#if node
trace = require './trace'
V = require './V'
O = require './O'
#endif




g_LOGIgnore = {}





#MOVE: to pre-processor
#H: what are the differences between these?
#UT: UT-ize
CNT = (o) ->
	a = []
	loop
		a.push.apply a, Object.getOwnPropertyNames o
		break unless o = Object.getPrototypeOf o
	a.length
CNT_OWN = (o) ->
	if o
		Object.getOwnPropertyNames(o).length
	else
		throw new Error "CNT_OWN: object is null!"
CNT_ENUM = (o) ->
	n = 0
	n++ for k of o
	n
CNT_ENUM_OWN = (o) -> Object.keys(o).length




KEYS = (o) ->
	a = []
	loop
		a.push.apply a, Object.getOwnPropertyNames o
		break unless o = Object.getPrototypeOf o
	a
KEYS_OWN = (o) -> Object.getOwnPropertyNames(o)
KEYS_ENUM = (o) ->
	a = []
	a.push(k) for k of o
	a
KEYS_ENUM_OWN = (o) -> Object.keys(o)







CLR_ENUM = (o) ->
	for k of o
		delete o[k]
	o
A_CLR_ENUM = ->
	for j in [0..arguments.length-1]
		CLR_ENUM arguments[j]
	return


CONTAINS_INSENSITIVE = (haystack, needle) -> S.CONTAINS_INSENSITIVE ""+haystack, ""+needle


DEEP_OPPOSITE = (o) ->
	tar = {}

	depth = 0
	loop
		for p in Object.getOwnPropertyNames o
			console.log "DEEP: #{depth} #{p} #{if p is "sql" then " *******************" else ""}"
			tar[p] = o[p]

		if o = Object.getPrototypeOf o
			depth++
		else
			return tar
DEEP = DEEP_TOO_MUCH_WORK = (o) ->
	a = []
	loop
		if o2 = Object.getPrototypeOf o
			a.push o
			o = o2
		else
			tar = {}
			for src,i in a.reverse()
#				console.log "object #{i}"
				for pn in Object.getOwnPropertyNames src
#					console.log "DEEP: #{pn} #{if pn is "sql" then " *******************" else ""}"
					tar[pn] = src[pn]
			return tar
DEEP_DNW = (o) ->
	tar = {}
	for k,v of o
		tar[k] = v
	tar



DFS_BREAKABLE = (o, fn) ->								#REC
	bContinue = true
	DFS_ = (o, depth) ->
		for k,v of o
			switch dt = IS.dt v
				when "a"
					unless bContinue = fn o, k, v, dt, depth
						return false

					for V,idx in v
						dt = IS.dt v

						unless bContinue = fn v, idx, V, dt, depth
							return false

						if dt is "o"
							unless bContinue = DFS_ V, depth+1
								return false
					return
				when "o"
					unless bContinue = fn o, k, v, dt, depth
						return false

					unless bContinue = DFS_ v, depth+1
						return false
				else
					unless bContinue = fn o, k, v, dt, depth
						return false
		true
	DFS_ o, 0



#USAGE: O.LOG_DRILL @owner, grep:"send",bValues:true
LOG_DRILL = (o, opts = {}) ->
	afterMsg = ""

	if opts.grep
		grepUC = opts.grep.toUpperCase()
		afterMsg = "GREP \"#{opts.grep}\""

	grep = (s) ->
		if opts.grep
			try
				test = "" + s
			catch ex
				test = ""
				console.log "grep: ex=#{ex}"

			if test.toUpperCase().includes(grepUC)
				true
			else
				false
		else
			true

	depth = 0
	loop
		console.log "#{" ".repeat depth * 8}#{"#{depth}".repeat 30} #{afterMsg}"

		for p in Object.getOwnPropertyNames(o).sort()
			if grep(p) or grep(o[p])
				if opts.bValues
					console.log "#{" ".repeat depth * 8}[#{depth}] #{V.KV p, o[p], true}"
				else
					console.log "#{" ".repeat depth * 8}[#{depth}] #{V.PAIR p, o[p]}"
#			LOG Object.getOwnPropertyDescriptor o, p
		if o = Object.getPrototypeOf o
			depth++
		else
			return
			


duck = (o) ->
	if o
		if typeof o is "object"
#			console.log "*********** #{o instanceof Object}"

			if o instanceof Object
				switch
					when o.hasOwnProperty "__cn"
						"Flexbase object"
					when o.hasOwnProperty "__CLASS_NAME"
						o.__CLASS_NAME
					else
						"OBJ"
			else
				"NAKED_OBJ"
		else if typeof o is "function"
			"FN"
		else
			o
	else
		"n-u-l-l"



#MOVE
SUMMARY = (o) ->
	kill = null

	try
		_c = _e = _w = 0
		highWaterMark = 0
		allPropCnt = 0	# may be off by 1
		allObjCnt = 0
		allSizeApprox = 0

		stack = []

		times = 0

		drill = (o, depth) ->
			if kill?
				return
			else if o?
				type = Object::toString.call o

#				console.log "depth=#{depth} type=#{type}"	# #{JSON.stringify o}

				switch type
					when '[object Object]'
						allObjCnt++
						allSizeApprox += 4		#GUESS
						if depth > highWaterMark
							highWaterMark = depth
						a = Object.getOwnPropertyNames o
						for p in a
							d = Object.getOwnPropertyDescriptor o, p

							if d.configurable
								_c++
							if d.enumerable
								_e++
							if d.writable
								_w++

							allPropCnt++

							stack.push p
							if stack.length > 3
#								console.log "stack: #{stack.join "/"}"

								for i in [0..stack.length-3]
#									console.log "i=#{i}"
									for j in [i+2..stack.length-3]
#										console.log "  j=#{j}   #{stack[i]}=#{stack[j]}   ...  #{stack[i+1]}=#{stack[j+1]}"

										if i isnt j and stack[i] is stack[j] and stack[i+1] is stack[j+1]
#											console.log "CYCLICAL at #{i} and #{j}"
#											console.log "stack: #{stack.join "/"}"
#											process.exit 1
											kill = "CYCLICAL at #{i} and #{j}: #{stack.join ','}"
											return
#							if times++ > 20
#								process.exit 1
							drill o[p], depth+1
							stack.pop()
					when '[object String]'
						allSizeApprox += o.length
					else
						allSizeApprox += 4

		drill o, 0

#		console.log "kill=#{kill}"

		CEW = "CEW(#{_c},#{_e},#{_w})"

		highWaterMark++

		switch allObjCnt
			when 0
				"NULL"
			when 1
				"#{duck o}: #{CEW} bytes=#{allSizeApprox}"
			else
				_ = "#{duck o}: props=#{CNT_OWN o} ///// "

				if kill
#					console.log "killed"
					return _ + kill
				else
#					console.log "not killed"
					return _ + "ALL: objs=#{allObjCnt} #{CEW} bytes=#{allSizeApprox} depth=#{highWaterMark}"
	catch ex
		console.log "CATCH: #{ex}"



DUMP = (o, opts={maxDepth:5}) ->
	DEBUG = 0

	if DEBUG
		V.LOG_MULTI o


	stack = []

	map = {}

	dump = (pn, v, depth, bChecking=true) ->
#		console.log "dump: depth=#{depth} #{JSON.stringify v}"

		type = Object::toString.call v

#		console.log "DEBUG: #{pn}=#{v} ARRAY=#{Array.isArray v} TYPEOF=#{typeof v} TYPE2=#{type} JSON=#{JSON.stringify v}"
#		V.LOG_SINGLE v, pn

		#TODO: pass pn as parameter
		indent = (s) -> console.log ">  #{" ".repeat depth * 8}#{if depth > 0 then " ∟ " else ""}#{if pn.length > 0 then "#{pn}:" else ""} #{s}"

		if Array.isArray v
			if v.length is 0
				indent "[]"
			else
				indent "ARRAY (len=#{v.length}):"

				for item,n in v
					dump "#{if pn.length > 0 and pn[0] isnt '[' then "" else ""}[#{n}]", item, depth+1, false
		else if v instanceof Error
			indent "details:"
			a = Object.getOwnPropertyNames v
			for pn in a
				dump pn, v[pn], depth+1
		else if v instanceof Uint8Array
#			console.log "111 #########################################"
			indent V.DUMP v
		else if type is '[object Arguments]'
			indent "found arguments (length=#{v.length})"
			for arg,i in v
#				indent "arguments[#{i}] = #{arg}"

#				indent "arguments[#{i}] ===================="
#				LOG arg

				dump "arguments[#{i}]", arg, depth+1
		else if type is '[object Object]'
#			console.log "object depth=#{depth}"

			kill = null
			stack.push pn
			if stack.length > 3
#				console.log "stack: #{stack.join "/"}"

				for i in [0..stack.length-3]
#					console.log "i=#{i}"
					for j in [i+2..stack.length-3]
#						console.log "  j=#{j}   #{stack[i]}=#{stack[j]}   ...  #{stack[i+1]}=#{stack[j+1]}"

						if i isnt j and stack[i] is stack[j] and stack[i+1] is stack[j+1]
#							console.log "CYCLICAL at #{i} and #{j}"
#							console.log "stack: #{stack.join "/"}"
#							process.exit 1
							kill = "CYCLICAL at #{i} and #{j}: #{stack.join ','}"
							kill = "CYCLICAL"

			if cnt = CNT_OWN v
#				console.log "xxx=#{depth}"
				if depth is opts.maxDepth
#					indent "#{duck v} (#{cnt}) at max"
					indent "#{SUMMARY v} *** TOO DEEP"
#					indent "*** TOO DEEP"
				else
					try
						indent "#{duck v} (#{cnt})"
					catch ex
						indent "duck exception (#{cnt}): ex=#{ex}"

					#				for pn of v
					#					console.log "of: pn=#{pn}"
					#
					#				#NOTE: "including non-enumerable properties except for those which use Symbol"
					#				for pn in Object.getOwnPropertyNames v
					#					console.log "Object.getOwnPropertyNames: pn=#{pn}"

					#TODO: identify non-enumerable properties just because!

					a = Object.keys v

					a.sort()
	#				indent "SORTED: #{a.join ","}"

					for pn in a
						if g_LOGIgnore[pn]
							dump pn, "**LogIgnore**", depth+1
						else
							unless kill
								if map[pn]?
									if ++map[pn] is 10
		#								indent "########## property: depth=#{depth} '#{pn}' has occurred too many times.  Stopped at #{MAX_PROPERTY_DEPTH}.  Circular structure?"
										kill = "########## '#{pn}' recursive"
								else
									map[pn] = 1

							if kill
#								indent "#{kill}: #{pn}"
								indent "#{kill}"
							else
								dump pn, v[pn], depth+1
			else
				indent "OBJ EMPTY"

			stack.pop()
		else
			indent V.DUMP v


	if arguments.length is 0
		console.log "WARNING: DUMP wasn't passed anything"
	else if arguments.length in [1, 2]
		dump "", o, 0
	else
		throw new Error "passed too many arguments!"







IS_EMPTY = (o) -> Object.keys(o).length is 0 and o.constructor is Object


#TODO: flag 'undefined' unless opt set
#SELF-CONTAINED
LOG = (o) ->
#	throw new Error "O.LOG!!!!!!!!!!!!!!!!!"

	DEBUG = 0

	if DEBUG
		V.LOG_MULTI o

	Q = ">  "

	if arguments.length is 0
		console.log "WARNING: LOG wasn't passed anything"
	else if arguments.length is 1
		DUMP o, maxDepth:5
	else
		if true
			for v,i in arguments
				unless v?
					console.log "#{Q}LOGARG[#{i}]: UNDEFINED"
				else if Object::toString.call(v) is '[object String]'
	#				console.log "#{v}"	# echo plain strings out directly as we find them
					console.log "#{Q}LOGARG[#{i}]: #{V.DUMP v}"
				else
					console.log "LOGARG[#{i}]:", v, 0
		else
			#TODO: put on a same line
			for v,i in arguments
				unless v?
					console.log "#{Q}LOGARG[#{i}]: UNDEFINED"
				else if Object::toString.call(v) is '[object String]'
	#				console.log "#{v}"	# echo plain strings out directly as we find them
					console.log "#{Q}LOGARG[#{i}]: #{V.DUMP v}"
				else
					console.log "LOGARG[#{i}]:", v, 0

	if DEBUG
		console.log "\n\n\n\n\n\n\n\n\n\n"

	return




		


module.exports =
	AllMethodsCSL: (object) ->
		a = []
		for pn of object
			a.push pn
		a.sort().join ","





#	CLR_ENUM:CLR_ENUM
#	A_CLR_ENUM:A_CLR_ENUM
#	CONTAINS_INSENSITIVE:CONTAINS_INSENSITIVE
#	DFS_BREAKABLE: DFS_BREAKABLE
#	DELTA: (o0, o1) ->
#		for k of o1
#			delete o0[k]
#		o0
#	DIFF: (a, b) ->												# a-b
#		o = Object.create null
#		for pn in KEYS a
#			o[pn] = b[pn] if pn !of b
#		o




	EQUALS: (o0, o1) ->
		leftChain=rightChain=null								#CLOSURE

		compareTwo = (o0, o1) ->
# remember that NaN===NaN returns false and isNaN(undefined) returns true
#GETTING: 0x800a1389 - Microsoft JScript runtime error: Number expected
#if !(o0 instanceof Object and o1 instanceof Object)
			if Object::toString.call(o0) is "[object Object]" and Object::toString.call(o1) is "[object Object]"
				return true if Object.keys(o0).length is 0 and Object.keys(o1).length is 0
			else
				return true if isNaN(o0) && isNaN(o1) && typeof o0 is 'number' && typeof o1 is 'number'

			# compare primitives and functions
			# check if both arguments reference the same object
			# especially useful on step when comparing prototypes
			return true if o0 is o1

			#IMPROVED: seems like "no brainer???"
			return false if o0 and !o1 or !o0 and o1

			# works in case when functions are created in constructor
			# comparing dates is a common scenario. Another built-ins?
			# we can even handle functions passed across iframes
			# precedence: instanceOf then && then ||
#			if typeof o0 is 'function' and typeof o1 is 'function'									or
#				o0 instanceof Date		and	o1 instanceof Date										or
#				o0 instanceof RegExp	and	o1 instanceof RegExp									or
#				o0 instanceof String	and	o1 instanceof String									r
#				o0 instanceof Number	and	o1 instanceof Number
#return o0.toString() is o1.toString()
#return o0.toString().replace /~/g, "|"  is o1.toString().replace / /g, ""
#				return o0.toString().replace(/\ /g, "") is o1.toString().replace /\ /g, ""
#
#			#IMPROVED: seems like "no brainer???"
#			return false if Object.keys(o0).length isnt Object.keys(o1).length
#
#
#			# check for infinitive linking loops
#			return false if leftChain.indexOf(o0) >= 0 || rightChain.indexOf(o1) >= 0
##
#			# quick checking of one object being a subset of another
#			#OPTIM: cache the structure of arguments[0]
#			for k of o1
##return false if o1.hasOwnProperty(k) isnt o0.hasOwnProperty(k)
#				return false if Object::hasOwnProperty.call(o0, k) isnt Object::hasOwnProperty.call(o1, k)
#				return false if typeof o1[k] isnt typeof o0[k]
#
#			for k of o0
##return false if o1.hasOwnProperty(k) isnt o0.hasOwnProperty(k)
#				return false if Object::hasOwnProperty.call(o0, k) isnt Object::hasOwnProperty.call(o1, k)
#				return false if typeof o1[k] isnt typeof o0[k]
#
#				switch typeof o0[k]
#					when 'object', 'function'
##CASE: NON-PRIMITIVE
#						leftChain.push o0
#						rightChain.push o1
#
#						return false if !compareTwo o0[k], o1[k]
#
#						leftChain.pop()
#						rightChain.pop()
#					else
##CASE: PRIMITIVE
#						return false if o0[k] isnt o1[k]
#
#			# at last checking prototypes as good as we can
#			#home grown objects don't neccessary inherit from Object: return false if !(o0 instanceof Object && o1 instanceof Object)
#			#return false if o0.isPrototypeOf(o1) || o1.isPrototypeOf(o0)
#			return false if Object::isPrototypeOf.call(o0, o1) || Object::isPrototypeOf.call(o1, o0)
#			return false if o0.constructor isnt o1.constructor
#			return false if o0.prototype isnt o1.prototype
#
#			true												#END: compareTwo
#
#		for j in [1..arguments.length-1]
#			leftChain = []
#			rightChain = []
#
#			return false if !compareTwo arguments[0], arguments[j]
#
#		true#/EQUALS
#	EQUALS_OBJECTS_THAT_ARE_CHAINED_TO_OBJECT_PROTOTYPE: (o0, o1) ->#NOT-USED
#		leftChain=rightChain=null								#CLOSURE
#
#		compareTwo = (o0, o1) ->
## remember that NaN===NaN returns false and isNaN(undefined) returns true
#			return true if isNaN(o0) && isNaN(o1) && typeof o0 is 'number' && typeof o1 is 'number'
#
#			# compare primitives and functions
#			# check if both arguments reference the same object
#			# especially useful on step when comparing prototypes
#			return true if o0 is o1
#
#			#IMPROVED: seems like "no brainer???"
#			return false if o0 and !o1 or !o0 and o1
#
#			# works in case when functions are created in constructor
#			# comparing dates is a common scenario. Another built-ins?
#			# we can even handle functions passed across iframes
#			# precedence: instanceOf then && then ||
#			if	typeof o0 is 'function'	&&	typeof o1 is 'function'									||
#				o0 instanceof Date		&&	o1 instanceof Date										||
#				o0 instanceof RegExp	&&	o1 instanceof RegExp									||
#				o0 instanceof String	&&	o1 instanceof String									||
#				o0 instanceof Number	&&	o1 instanceof Number
##return o0.toString() is o1.toString()
##return o0.toString().replace /~/g, "|"  is o1.toString().replace / /g, ""
#				return o0.toString().replace(/\ /g, "") is o1.toString().replace /\ /g, ""
#
#			# at last checking prototypes as good as we can
#			return false if !(o0 instanceof Object && o1 instanceof Object)
#			return false if o0.isPrototypeOf(o1) || o1.isPrototypeOf(o0)
#			return false if o0.constructor isnt o1.constructor
#			return false if o0.prototype isnt o1.prototype
#
#			#IMPROVED: seems like "no brainer???"
#			return false if Object.keys(o0).length isnt Object.keys(o1).length
#
#
#			# check for infinitive linking loops
#			return false if leftChain.indexOf(o0) >= 0 || rightChain.indexOf(o1) >= 0
#
#			# quick checking of one object being a subset of another
#			#OPTIM: cache the structure of arguments[0]
#			for k of o1
#				return false if o1.hasOwnProperty(k) isnt o0.hasOwnProperty(k)
#				return false if typeof o1[k] isnt typeof o0[k]
#
#			for k of o0
#				return false if o1.hasOwnProperty(k) isnt o0.hasOwnProperty(k)
#				return false if typeof o1[k] isnt typeof o0[k]
#
#				switch typeof o0[k]
#					when 'object', 'function'
##CASE: NON-PRIMITIVE
#						leftChain.push o0
#						rightChain.push o1
#
#						return false if !compareTwo o0[k], o1[k]
#
#						leftChain.pop()
#						rightChain.pop()
#					else
##CASE: PRIMITIVE
#						return false if o0[k] isnt o1[k]
#
#			true												#END: compareTwo
#
#		for j in [1..arguments.length-1]
#			leftChain = []
#			rightChain = []
#
#			return false if !compareTwo arguments[0], arguments[j]
#
#		true#/EQUALS_OBJECTS_THAT_ARE_CHAINED_TO_OBJECT_PROTOTYPE
#	I: (o) ->
#		if typeof o is "number"
#			o
#		else
#			parseInt o, 10
#	IS_EMPTY: (o) ->
#		for k of @KEYS o
#			return false
#		true
#
	CNT:CNT
	CNT_OWN:CNT_OWN
	CNT_ENUM:CNT_ENUM
	CNT_ENUM_OWN:CNT_ENUM_OWN

	DEEP: DEEP

	duck: duck

	DUMP: DUMP
	
	LOG_DRILL: LOG_DRILL

	INTERSECTS_ENUM: (o0, o1) ->
		for k of o0
			return true if k of o1
		false

	IS_EMPTY: IS_EMPTY

	KEYS:KEYS
	KEYS_OWN:KEYS_OWN
	KEYS_ENUM:KEYS_ENUM
	KEYS_ENUM_OWN:KEYS_ENUM_OWN

	LOG: LOG
	LOGIgnore: g_LOGIgnore

	SUMMARY:SUMMARY


#	N: (o) ->
#		if typeof o is "number"
#			o
#		else if R.RE.TEST_PLUS_MINUS_FLOAT.test o
#			parseFloat o, 10
#		else
#			throw o
#	SUB_SUP_PROP_VALUES_EQUALS: (sub, sup) ->
#		for k of sub
#			return false unless sup[k]?
#			return false unless R.O.EQUALS sub[k], sup[k]
#		true


#if ut
	s_ut: ->
		UT = require './UT'

		(new (class O_UT extends UT
			run: ->
				@s "DUMP", ->
					fn = (o, opts) =>
						if trace.HUMAN
#							@log "IN:  #{JSON.stringify o}", o
							@log "IN:  ", o
							@log '-'.repeat 40
							DUMP o, opts
							@log '='.repeat 150
					@t "simple", ->
						fn {top:55, second:{atSecond:true}}
					@t "maxDepth", ->
						fn {top:55, second:{atSecond:true}}, {maxDepth:1}
				@s "LOG", (ut) ->
					@t "simple", (ut) ->
						if trace.HUMAN
							LOG null
							LOG 3.1415926
							LOG a:"a"
							LOG ["a","b"]
							LOG [[[["a","b"],"c"],"b"],"c"]

							o = {}
							o.z = "some value"
							o.a = "some value"
							o.q = "some value"
							o.k = "some value"
							o.r = "some value"
							for p of o
								@log "p=#{p}"
							LOG o
					@t "multiple parameters", (ut) ->
						if trace.HUMAN
							LOG "peter", "charles", "alvin"
							LOG {"a":"peter"}, {"b":"charles"}, {"c":"alvin"}
					@s "LOG_DRILL", ->
						#PATTERN: ancestor function called by children
						@create = ->
							o1 = a:"aaa"
							o2 = Object.create o1
							o2.b = "bbb"
							o3 = Object.create o2
							o3.c = "ccc"
							o3
							@t "trivial3", ->
								if trace.HUMAN
									LOG_DRILL @create()
							@t "values", ->
								if trace.HUMAN
									LOG_DRILL @create(), bValues:true
							@t "grep", ->
								if trace.HUMAN
									LOG_DRILL @create(), bValues:true, grep:"to"
				@s "SUMMARY", ->
					fn = (o) =>
						s = SUMMARY o

						if trace.HUMAN
#							@log "IN:  #{JSON.stringify o}", o
							@log "IN:  ", o
							@log "OUT: #{s}"
							@log '='.repeat 150
					@t "CEW", ->
						o = {}
						for c in [false, true]
							for e in [false, true]
								for w in [false, true]
									pn = "#{if c then 'C' else '_'}#{if e then 'E' else '_'}#{if w then 'W' else '_'}"
									Object.defineProperty o, pn,
										configurable: c
										enumerable: e
										value: pn,
										writable: w
						fn o
					@t "simple", ->
						fn {top:55, second:{atSecond:true}}
					@t "cyclical", ->
						o1 =
							a: "a"
						o2 =
							b: "b"
							o1: o1
						o1.o2 = o2
						fn o1

		)).run()
#endif