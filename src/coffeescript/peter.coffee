PETER=8

O = require './O'
trace = require './trace'





log = (line) -> process.stdout.write line + '\n'
log = (line) -> console.log line + '\n'

lg = (line) -> console.log line



process = (code, ENV = {}) ->
#	log "process: ENV=#{JSON.stringify ENV}"

	code = code.toString()

#	log "FILE: SRC1: #{code}\n"

	a = []

	stack = []

	arg = (line) ->
		tokens = line.split ' '
#		log "arg: #{tokens[1]}"
		tokens[1]

	req =
		bGo: true

	lines = code.split '\n'

	#TODO #EASY: add ifdef end
	#TODO: add switch, elseif?

	for line,lineNbr in lines
#		line = line.replace /?harles/, 'Christmas'

		lg "#{lineNbr+1} LINE: #{line}"

		#SLOW
		th = (msg) -> throw new Error "line=#{lineNbr+1}: depth=#{stack.length}#{if req.name then " name=#{req.name}" else ""}: #{msg}"

		switch
			when line[0..2] is "#if"
#				log "IF: line=#{line}: #{req.bGo}"

				# save current requirements for later
				stack.push req

				#CHALLENGE: why clone?  appears to break if just set req={}   !!!
				# clone (otherwise side offect of messing with requirements object just saved)
				req = Object.assign {}, req

				# the default is that this #if section is DEAD.  BUT, if bGo is true, then not dead: we need to flip when it else
				req.bFlipOnElse = false
				if req.bGo
					req.bFlipOnElse = true
					req.bFoundELSE = false
					req.bFoundIF = true
					req.name = arg line

					# only go if this target is one of the environments
					req.bGo = !!ENV[req.name]
#					log "IF: name=#{req.name} bGo=#{req.bGo}"
			when line[0..4] is "#else"
				if req.bFoundELSE
					th "#else duplicated"
				else
					req.bFoundELSE = true

				unless req.bFoundIF
					th "#else without #if"

				if req.bFlipOnElse
					# we're alive, so flip... whatever the logic was, now it's the opposite
					req.bGo = ! req.bGo
			when line[0..5] is "#endif"
				if stack.length > 0
					req = stack.pop()
				else
					th "#endif without #if"
			else
				a.push line if req.bGo

	if req.bFoundIF
		throw new Error "line=#{lineNbr+1} #endif missing"

	a.join '\n'






module.exports =
#if ut
	s_ut: ->
		UT = require './UT'

		(new (class PeterUT extends UT
			run: ->
				@s "process", ->
					removePeriod = (code) ->
						lines = code.split '\n'

						for line,lineNbr in lines
							if line.length > 0 and line[0] is '.'
								lines[lineNbr] = line[1..]
						lines.join '\n'




					fn = (c1,c2,ENV, that) =>
						c1 = removePeriod c1
						c2 = removePeriod c2
#						console.log "====================BEFORE================ ENV=#{JSON.stringify ENV}"
#						console.log c1
#						console.log "-----------------------------------------------"
#						console.log c2
#						console.log "-----------------------------------------------"
						rv = process c1, ENV
						that.eq rv, c2



					@t "trivial", ->
						c1 = """
.abc
.def
"""
						c2 = """
.abc
.def
"""
						fn c1, c2, {}, this
					@t "if: env=", ->
						c1 = """
.before
.#if rn
.this is rn
.#else
.this is NOT rn
.#endif
.after
"""
						c2 = """
.before
.this is NOT rn
.after
"""
						fn c1, c2, {}, this
					@t "if: env=rn", ->
						c1 = """
.before
.#if rn
.this is rn
.#else
.this is NOT rn
.#endif
.after
"""
						c2 = """
.before
.this is rn
.after
"""
						fn c1, c2, {rn:true}, this
					@t "nested if: env=emily", ->
						c1 = """
.before
.#if rn
.this is rn
.#else
.this is NOT rn
.#if emily
.this is emily
.#else
.this is NOT emily
.#endif
.#endif
.after
"""
						c2 = """
.before
.this is NOT rn
.this is emily
.after
"""
						fn c1, c2, {emily:true}, this
					@t "#else", exceptionMessage:"line=2: depth=0: #else without #if", ->
						c1 = """
.abc
.#else
.def
"""
						fn c1, "", {rn:true}, this
					@t "#endif", exceptionMessage:"line=2: depth=0: #endif without #if", ->
						c1 = """
.abc
.#endif
.def
"""
						fn c1, "", {rn:true}, this
					@t "#else duplicated", exceptionMessage:"line=6: depth=1 name=rn: #else duplicated", ->
						c1 = """
.before
.#if rn
.this is rn
.#else
.this is NOT rn
.#else
.after 2nd else
.#endif
.after
"""
						fn c1, "", {}, this
					@t "#endif missing", exceptionMessage:"line=6 #endif missing", ->
						c1 = """
.before
.#if rn
.this is rn
.#else
.this is NOT rn
"""
						fn c1, "", {}, this
					@t "#endif missing (nested)", exceptionMessage:"line=8 #endif missing", ->
						c1 = """
.before
.#if rn
.this is rn
.#if ALONE
.#else
.this is NOT rn
.#endif
"""
						fn c1, "", {}, this
		)).run()
#endif

	process: process