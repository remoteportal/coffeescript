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

	req =
		bGo: 1		# 0=off 1=on

	lines = code.split '\n'
	for line,i in lines
#		line = line.replace /Charles/, 'Christmas'

		switch
			when line[0..2] is "#if"
#				req.bGo
				stack.push req

				req = Object.assign {}, req
				req.bFlipOnElse = false
				if req.bGo
					req.bFlipOnElse = true

					name = arg line
					req.bGo = ENV[name]
#				else
#					req[] = true
#					req.bIf = true
#					lg "if:req=#{JSON.stringify req}"

			when line[0..4] is "#else"
				if req.bFlipOnElse
					req.bGo = ! req.bGo
			when line[0..5] is "#endif"
				req = stack.pop()
			else
				a.push line if req.bGo
#				unless req.bSuppress
#					if O.CNT_OWN(req) is 0
#	#					log "empty"
#						a.push line
#					else
#	# make sure all requirements satisfied
#						bGo = true
#						for k of req
#							log "found #{k}"
#							if req[k]
#	#							log "eval"
#								bGo &= ENV[k]
#							log "bGo=#{bGo}"
#						if bGo
#							if req.last is "if"	#HACK
#								log "req.bSuppressElse = true"
#								req.bSuppressElse = true
#							a.push line
#						else
#							lg "SKIP: #{line}"
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
#						console.log "====================BEFORE================ ENV=#{JSON.stringify ENV}"
#						console.log c1
#						console.log "-----------------------------------------------"
#						console.log c2
#						console.log "-----------------------------------------------"
						rv = process c1, ENV
						that.eq rv, c2



					@t "trivial", ->
						c1 = """
abc
def
"""
						c2 = """
abc
def
"""
						fn c1, c2, {}, this
					@t "if: env=", ->
						c1 = """
before
#if rn
this is rn
#else
this is NOT rn
#endif
after
"""
						c2 = """
before
this is NOT rn
after
"""
						fn c1, c2, {}, this
					@T "if: env=rn", ->
						c1 = """
before
#if rn
this is rn
#else
this is NOT rn
#endif
after
"""
						c2 = """
before
this is rn
after
"""
						fn c1, c2, {rn:true}, this
					@t "nested if: env=rn", ->
						c1 = """
before
#if rn
this is rn
#else
this is NOT rn
#endif
after
"""
						c2 = """
before
this is NOT rn
after
"""
						fn c1, c2, {rn:false}, this
		)).run()
#endif

	process: process