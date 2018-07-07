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



COMPARE_REPORT = (s0, s1) ->		#H: string-oriented or value (V)-oriented?
	buf = ''

	if s0 is s1
		buf = "values are the same"
	else
		bStrings = true
		for s in [s0, s1]
			bStrings = false		unless IS s

		if bStrings
			buf += "---------------------LEN------------------\n"
			for s in [s0, s1]
				buf += "length=#{s.length}\n"

			buf += "---------------------VALUES----------------------\n"
			for s in [s0, s1]
				# buf += "> arg#{i}: #{V.PAIR arguments[i]}\n\n"
				buf += "#{V.PAIR s}\n\n"

			# classify: completely different, pre-pended, appended, middle different
#			i = 0
#			if s0.length


			buf += "---------------------IDENTICAL PORTION (UP TO [#{}])----------------------\n"
			for s in [s0, s1]
				buf += "#{V.PAIR s}\n\n"

			buf += "---------------------HEX------------------\n"
			for s in [s0, s1]
				buf += "#{HEX s}\n\n"

			buf += "-------------------------------------------\n"
		else
			for s in [s0, s1]
				buf += "#{V.PAIR s}\n\n"

	buf



F = (o) ->
	O = require './O'
	O.LOG o
	for item,v of o
		console.log item, v


HEX = (s) ->
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

		#				buf += " #{idx++}: #{c2} #{hex}"
		buf += "  #{c2} #{hex}"
	buf

IS = (v) -> Object::toString.call(v) is "[object String]"




module.exports =
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
		)).run()
#endif


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

	#				buf += " #{idx++}: #{c2} #{hex}"
					buf += "  #{c2} #{hex}"
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