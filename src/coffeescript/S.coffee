###
V - String functions					*** PROJECT AGNOSTIC ***


WHAT: Node module


DESCRIPTION



FEATURES
-


NOTES
-


TODOs
- UT		#H


KNOWN BUGS:
-
###



C = require './C'
trace = require './trace'
V = require './V'




stringifySafe = (o) ->
	if o isnt null and typeof o is 'object'
		s = ""

		for pn of o
			s += "#{pn}=${o[pn]} "

		s
	else
		o





autoTable = (data, opts = {bHeader: true}) ->
#	data = Object.assign {}, data

	if opts.grep
		console.log "filter: #{opts.grep}"
		opts.grep = opts.grep.toUpperCase()

	ignoreMap = {}
	if opts.ignore
		for cn in opts.ignore.split ","
#			console.log cn
			ignoreMap[cn] = true

	O = require './O'
	if Array.isArray data
		data = data.slice 0
		columnMap = new Map()
		pass = ->
			for row in data
				if V.type(row) is "object"
					for k,v of row
						if v
							s = "" + v
						else
							s = "•"
						if _=columnMap.get(k)
							columnMap.set k, Math.max(_, s.length)
						else
							columnMap.set k, s.length
				else
					throw "NOT-IMPL"
#		columnMap.forEach (v,k) =>
#			console.log "each", "k=#{k} v=#{v}"
		pass()
		if opts.bHeader
			o = {}
			columnMap.forEach (v,k) =>
				unless ignoreMap[k]
					o[k] = k.toUpperCase()
			data.splice 0, 0, o
			pass()		# re-compute max column widths including new header strings

		buf = ""
		for row in data
			if opts.grep
				bFound = false
				columnMap.forEach (v,k) =>
					if (""+row[k]).toUpperCase().includes opts.grep
						bFound = true
				unless bFound
					continue

			buf += "\n"
			if V.type(row) is "object"
				columnMap.forEach (v,k) =>
					unless ignoreMap[k]
#						console.log "k=#{k}"
						buf += ((if row[k] then ""+row[k] else "•").substring(0,v).padEnd v+1)
#		console.log buf
		buf
	else
		throw "autoTable: NOT-IMP"
#	process.exit 1



CAP = (s) -> "#{s[0].toUpperCase()}#{if s.length > 1 then s.slice(1).toLowerCase() else ""}"


HAS_INSERTED_TEXT_IN_MIDDLE = (a,b) ->
	"don't care"
	false
#EASY
#COOL: optionsMap for detailLevel: 1) enum, 2) one-liner, or 3) multi-line-full-report
COMPARE_REPORT = (s1, s2, options = {}) ->		#H: string-oriented or value (V)-oriented?
#EASY O.VALIDATE_OBJECT to make sure "preamble" is a valid option!


	buf = ''

	
	endsDifferReport = (s1, s2) ->
		if s1.length > 0 and s2.length > 0
			i = 0
			for i in [0..s1.length-1]
				break if s1[i] != s2[i]

			if i is 0
				null
			else
				_  = "---------------------IDENTICAL PORTION (UP TO INDEX [#{i-1}])----------------------\n"
				_ += "#{s1[0..i-1]}\n"
				_ += "---------------------DIFFERENT ENDINGS----------------------\n"
				_ += "#{s1[i..]} (#{s1[i..].length})\n\n"
				_ += "#{s2[i..]} (#{s2[i..].length})"
				_
		else
			throw new Error "xxxxxxx"



	if s1 is s2
		buf = "strings are the same"		#HACK: cannot I not say more?
	else
		bStrings = true
		for s in [s1, s2]
			bStrings = false		unless IS s

		if bStrings
			if options.preamble?
				buf += "---------------------PREAMBLE------------------\n"
				buf += options.preamble + '\n'

			buf += "---------------------LEN------------------\n"
			for s in [s1, s2]
				buf += "length=#{s.length}\n"


			buf += "---------------------VALUES----------------------\n"
			buf += "#{s1}\n\n"
			buf += "#{s2}\n"


			h = "---------------------ANALYSIS & INTERPRETATION----------------------\n"
			# classify: completely different, pre-pended, appended, middle different
			switch
#EASY
				when _=endsDifferReport s1, s2
					buf += _
				when s1.toUpperCase() is s2
					buf += "#{h}differ only by case"
				when s1 is s2.toUpperCase()
					buf += "#{h}differ only by case"
				when HAS_INSERTED_TEXT_IN_MIDDLE s1, s2
#EASY
# 					# embedded
# 					s1=aabbcc
# 					s2=aacc
					buf += "#{h}embedded TODO"
				when s1.endsWith s2
					buf += "#{h}s1 ends with s2"
				when s1.startsWith s2
					buf += "#{h}s1 startsWith s2"
				when s2.endsWith s1
					buf += "#{h}s2 ends with s1"
				when s2.startsWith s1
					buf += "#{h}s2 startsWith s1"
				else
					buf += "#{h}some other difference"
			buf += "\n"


			buf += "---------------------HEX------------------\n"
			buf += "#{HEX s1}\n\n"
			buf += "#{HEX s1}\n"


			buf += "-------------------------------------------\n"
		else
			throw new Error "NOT STRINGS!"

	buf



F = (o) ->
	O = require './O'
	O.LOG o
	for item,v of o
		console.log item, v



#OPTIONS: bPrependChar, maxBytes
#COOL: options map is cool because they can be passed into sub-functions
#EASY: number of bytes per line
#EASY: english SPACE or always hex 0x20
HEX = (s, options = {} ) ->
	a = [
		C.BACKSPACE
		"BS"
		C.TAB
		"TAB"
		C.LF
		"LF"
		C.CR
		"CR"
		C.SHIFT
		"SHIFT"
		C.CTRL
		"CTRL"
		C.ALT
		"ALT"
		C.ESC
		"ESC"
		C.SPACE
		"SPACE"
		C.PAGE_UP
		"PAGE_UP"
		C.PAGE_DOWN
		"PAGE_DOWN"
		C.END
		"END"
		C.HOME
		"HOME"
		C.LEFT
		"LEFT"
		C.UP
		"UP"
		C.RIGHT
		"RIGHT"
		C.DOWN
		"DOWN"
		C.INSERT
		"INSERT"
		C.DELETE
		"DELETE"
		C.F1
		"F1"
		C.F2
		"F2"
		C.F3
		"F3"
		C.F4
		"F4"
		C.F5
		"F5"
		C.F6
		"F6"
		C.F7
		"F7"
		C.F8
		"F8"
		C.F9
		"F9"
		C.F10
		"F10"
		C.F11
		"F11"
		C.F12
		"F12"
	]

	special = Object.create null

	while a.length > 0
		special["_"+a.shift()] = a.shift()	#H: why doesn't this work with "_"?   special appears to NEVER POPULATE

	buf = ""
	
	idx = 0
	a = s.split ""
	while c = a.shift()
		unicode = c.charCodeAt 0

		hex = unicode.toString 16	#PATTERN:HEX
		if hex.length is 1
			hex = "0#{hex}"

		if c2 = special["_"+unicode]
			css = "c-special"
		else
			css = "c"
			c2 = c

		# buf += " #{idx}: #{c2} #{hex}"
		if options.bPrependChar
			buf += "  #{c2} #{hex}"
		else
			buf += "#{hex}"

		idx++

		if options.maxBytes? and options.maxBytes is idx
			break

	buf

IS = (v) -> Object::toString.call(v) is "[object String]"




module.exports =
	autoTable: autoTable
	CAP: CAP
	COMPARE_REPORT: COMPARE_REPORT
	DUMP: (s, max=256, bHEX) ->
		if IS s
			unless s?
				len = 0
				max = 0
				s = "NULL"
			else unless s
				len = 0
				max = 0
				s = "EMPTY"
			else
				len = s.length
				max = Math.min s.length, max

	# ************ #{bHEX} #{max}
			buf = "#{s} (#{len})"

			if bHEX and max > 0
				buf += HEX s
			buf
		else
			""			#H: what to do?
#	DUMP_HTML: (s, max=256, bHEX) ->
#		unless s?
#			len = 0
#			max = 0
#			s = "NULL"
#		else unless s
#			len = 0
#			max = 0
#			s = "EMPTY"
#		else
#			len = s.length
#			max = Math.min s.length, max
#
#		buf = "<span class='dump-s'>#{s}</span>"
#		buf += "<span class='dump-len'>#{len}</span>"
#
#		if bHEX and max > 0
#			a = [
#				C.BACKSPACE
#				"BS"
#				C.TAB
#				"TAB"
#				C.LF
#				"LF"
#				C.CR
#				"CR"
#				C.SHIFT
#				"SHIFT"
#				C.CTRL
#				"CTRL"
#				C.ALT
#				"ALT"
#				C.ESC
#				"ESC"
#				C.SPACE
#				"SPACE"
#				C.PAGE_UP
#				"PAGE_UP"
#				C.PAGE_DOWN
#				"PAGE_DOWN"
#				C.END
#				"END"
#				C.HOME
#				"HOME"
#				C.LEFT
#				"LEFT"
#				C.UP
#				"UP"
#				C.RIGHT
#				"RIGHT"
#				C.DOWN
#				"DOWN"
#				C.INSERT
#				"INSERT"
#				C.DELETE
#				"DELETE"
#				C.F1
#				"F1"
#				C.F2
#				"F2"
#				C.F3
#				"F3"
#				C.F4
#				"F4"
#				C.F5
#				"F5"
#				C.F6
#				"F6"
#				C.F7
#				"F7"
#				C.F8
#				"F8"
#				C.F9
#				"F9"
#				C.F10
#				"F10"
#				C.F11
#				"F11"
#				C.F12
#				"F12"
#			]
#
#			special = Object.create null
#
#			while a.length > 0
#				special["_"+a.shift()] = a.shift()	#H: why doesn't this work with "_"?   special appears to NEVER POPULATE
#
#			idx = 0
#			a = s.split ""
#			while c = a.shift()
#				unicode = c.charCodeAt 0
#
#				hex = unicode.toString 16	#PATTERN:HEX
#				if hex.length is 1
#					hex = "0#{hex}"
#
#				if c2 = special["_"+unicode]
#					css = "c-special"
#				else
#					css = "c"
#					c2 = c
#
#				buf += "<span class='dump-idx'>#{idx++}</span><span class='dump-#{css}'>#{c2}</span><span class='dump-hex'>#{hex}</span>"
#		buf
	enumCheck: (target, css) -> (",#{css},").contains ",#{target},"
	HEX: HEX
	IS: IS




#if ut
	s_ut: ->
		UT = require './UT'

		(new (class SUT extends UT
			run: ->
				@t "autoTable", ->
					a = [
						{
							peter: "peter"
							empty: null
						}
					,
						{
							peter: 3.14159
						}
					,
						{
							alvin: "alvin"
						}
					]

					_ = autoTable(a, {bHeader:false})
					@eq _.length, 51
					@logg trace.HUMAN, _

					_ = autoTable(a)
					@eq _.length, 84
					@logg trace.HUMAN, _
				@t "CAP", ->
					@eq CAP("peter"), "Peter"
				@_t "F", ->		#EXPERIMENTAL
					@eq F("#{"abc":10}"), ""
				@t "IS", ->
					@assert IS "hello"
					@assert !IS 4
				@s "COMPARE_REPORT", ->
					@t "differ only by case", ->
						s = COMPARE_REPORT "peter", "PETER"
						@logg trace.HUMAN, s
					@_t "s1 is s2 but s1 has inserted characters in middle", ->
						s = COMPARE_REPORT "aa_THIS IS INSERTED_IN_MIDDLE_cc", "aacc"
						@logg trace.HUMAN, s
					@t "ends differ", ->
						s = COMPARE_REPORT "abcdefg1234567", "abcdefgABC"
						@logg trace.HUMAN, '^' + s
		)).run()
#endif