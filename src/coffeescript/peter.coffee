trace = require './trace'




log = (line) -> process.stdout.write line + '\n'
printWarn = (line) -> process.stderr.write line + '\n'


process = (code, ENV) ->
	log "process"

	code = code.toString()

	log "FILE: SRC1: #{code}\n"

	a = []

	req = {}		#required

	stack = []

	arg = (line) ->
		log "arg"

	lines = code.split '\n'
	for line,i in lines
		line = line.replace /Charles/, 'Christmas'

		switch
			when line[0..2] is "#if"
				log line
				o = {}
				o[last = arg(line)] = true
				stack.push o
				compute()
			when line[0..4] is "#else"
				log line
				stack[stack.length-1][last] ^= true
				compute()
			when line[0..5] is "#endif"
				log line
				compute()
			else
				if CNT_OWN(req) is 0
# nothing required!
					a.push line
				else
# make sure all requirements satisfied
					bGo = true
					for k of req
						if req[k]
							bGo &= cur[k]
					if bGo
						a.push line
	#		lines[i] = line
	#		log "LINE: #{line}"

	_ = a.join '\n'
	log "AFTER: #{_}\n"
	_








module.exports =
#if ut
	s_ut: ->
		UT = require './UT'

		(new (class PeterUT extends UT
			run: ->
				@t "process", (ut) ->
		)).run()
#endif

	process: process