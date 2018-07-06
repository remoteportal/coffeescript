O = require './O'
trace = require './trace'




log = (line) -> process.stdout.write line + '\n'
log = (line) -> console.log line + '\n'

lg = (line) -> console.log line



process = (code, ENV = {}) ->
#	log "process"

	code = code.toString()

#	log "FILE: SRC1: #{code}\n"

	a = []

	stack = []

	name = null

	arg = (line) ->
		tokens = line.split ' '
#		log "arg: #{tokens[1]}"
		tokens[1]

	compute = ->

	cur = {}

	lines = code.split '\n'
	for line,i in lines
#		line = line.replace /Charles/, 'Christmas'

		switch
			when line[0..2] is "#if"
#				log line
				stack.push cur
				cur = Object.assign {}, cur
				cur[name = arg(line)] = true
#				O.DUMP cur
				compute()
			when line[0..4] is "#else"
#				log line
#				stack[stack.length-1][name] ^= true
				cur[name] ^= true
				compute()
			when line[0..5] is "#endif"
#				log line
				cur = stack.pop()
			else
				if O.CNT_OWN(cur) is 0
#					log "empty"
					a.push line
				else
# make sure all requirements satisfied
					bGo = true
					for k of cur
						if cur[k]
							bGo &= ENV[k]
					if bGo
						a.push line
#					else
#						lg "SKIP: #{line}"
	#		lines[i] = line
	#		log "LINE: #{line}"

	_ = a.join '\n'
#	log "========== AFTER"
#	log _
	_








module.exports =
#if ut
	s_ut: ->
		UT = require './UT'

		(new (class PeterUT extends UT
			run: ->
				@s "process", ->
					fn = (c1,c2,ENV, that) =>
						console.log "====================BEFORE================ ENV=#{ENV}"
						console.log c1
						console.log "-----"
						console.log c2
						rv = process c1, c2, ENV
						that.eq rv, c2

					@_t "simple", ->
						c1 = """
one
two
three
"""
						c2 = process c1
						@eq c1, c2
					@t "if", ->
						c1 = """
before
#if rn
this is rn
#endif
after
"""
						c2 = """
before
after
"""
						fn c1, c2, {}, this
		)).run()
#endif

	process: process