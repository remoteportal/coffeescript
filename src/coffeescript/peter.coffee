OUTPUT=0

O = require './O'
trace = require './trace'




log = (line) -> process.stdout.write line + '\n'
log = (line) -> console.log line + '\n'

lg = (line) -> console.log line



process = (code, ENV = {}) ->
	if OUTPUT
		log "process: ENV=#{JSON.stringify ENV}"

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
		bFoundIF: false
		bFoundELSE: false


	lines = code.split '\n'

	#TODO #EASY: add ifdef end
	#TODO: add switch, elseif?
	#TODO: residue comment: //if node

	for line,lineNbr in lines
#		line = line.replace /?harles/, 'Christmas'

#		lg "BEFORE: LINE #{lineNbr+1}: #{line}"

		#SLOW: set for EACH LINE!
		th = (msg) ->
			start = Math.max 0, lineNbr-20
			lg "------------------------"
			for i in [start..lineNbr]
				lg "CONTEXT: LINE #{i+1}: #{lines[i]}"
			if OUTPUT
				throw new Error "line=#{lineNbr+1}: depth=#{stack.length} ENV=#{JSON.stringify ENV} stack=#{JSON.stringify stack}#{if req.name then " name=#{req.name}" else ""}: #{msg}"
			else
				throw new Error "line=#{lineNbr+1}: depth=#{stack.length}#{if req.name then " name=#{req.name}" else ""}: #{msg}"

		doReq = (name, bFlipIII) ->
# 			the default is that this #if section is DEAD.  BUT, if bGo is true, then not dead: we need to flip inside #else
			req.bFlipOnElse = false

#			log "bFoundELSE=false for #{name}"
			req.bFoundELSE = false

			if req.bGo
				req.name = name
				req.bFlipOnElse = true
				req.bFoundIF = true

				if req.name not in ["0","1","ut","node","rn","cs","bin"]
					th "unknown"

				# only go if this target is one of the environments
				req.bGo = if req.name is "0" then false else !!ENV[req.name]
				req.bGo = if req.name is "1" then true else req.bGo
#				req.bAlive = ! req.bGo
#				log "IF: name=#{req.name} bGo=#{req.bGo}"
		switch
			when line[0..2] is "#if"
				a.push line if OUTPUT
#				log "IF: line=#{line}: #{req.bGo}"
				name = arg line

				# save current requirements for later
				stack.push req

				#CHALLENGE: why clone?  appears to break if just set req={}   !!!
				# clone (otherwise side offect of messing with requirements object just saved)
				req = Object.assign {}, req
				doReq name, true
				req.bChainSatisfied = req.bGo
			when line[0..6] is "#elseif"
				a.push line if OUTPUT
				if req.bFoundELSE
					th "#elseif following #else"

#				lg "elseif: satis=#{req.bChainSatisfied}"
				if req.bChainSatisfied
					# chain is henceforth DEAD!
					req.bGo = false
					req.bFlipOnElse = false			# turn off '#else'
				else
					name = arg line

					# replace requirements with new name, keep same requirement object
					req.bGo = true
					doReq name
			when line[0..4] is "#else"
				a.push line if OUTPUT
				unless req.bFoundIF
					th "#else without #if"

				if req.bFoundELSE
					th "#else duplicated"
				else
					req.bFoundELSE = true

				if req.bFlipOnElse
					# we're alive, so flip... whatever the logic was, now it's the opposite
					req.bGo = ! req.bGo
			when line[0..5] is "#endif"
				a.push line if OUTPUT
				if stack.length > 0
					# return to requirements before first #if of this current chain was encountered
					req = stack.pop()
				else
					th "#endif without #if"
			else
				a.push line if req.bGo

	if req.bFoundIF
#		throw new Error "line=#{lineNbr+1} #endif missing: #{JSON.stringify stack}"
#		throw new Error "line=#{lineNbr+1} #endif missing: #{JSON.stringify stack.forEach((o) -> o.name)}"
		throw new Error "line=#{lineNbr+1} #endif missing: \"#{req.name}\""

	for line,lineNbr in a
		lg "AFTER: LINE #{lineNbr+1}: #{line}"

#	"# IF-COFFEE: ENV=#{JSON.stringify ENV}\n" + a.join '\n'
	a.join '\n'




#TODO: #elseif rn

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
					@t "if 0", ->
						c1 = """
.#if 0
.NO
.#else
.YES
.#endif
"""
						c2 = """
.YES
"""
						fn c1, c2, {}, this
					@t "if 1", ->
						c1 = """
.#if 1
.YES
.#else
.NO
.#endif
"""
						c2 = """
.YES
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
					@t "#elseif: case 1  (chain #if rn)", ->
						c1 = """
.before
.#if rn
.this is rn
.#elseif node
.this is node
.#else
.neither
.#endif
.after
"""
						c2 = """
.before
.this is rn
.after
"""
						fn c1, c2, {rn:true, node:true}, this
					@t "#elseif: case 2 (chain #elseif node)", ->
						c1 = """
.before
.#if rn
.this is rn
.#elseif node
.this is node
.#else
.neither
.#endif
.after
"""
						c2 = """
.before
.this is node
.after
"""
						fn c1, c2, {rn:false, node:true}, this
					@t "#elseif: case 3 (chain #else)", ->
						c1 = """
.before
.#if rn
.this is rn
.#elseif node
.this is node
.#else
.neither
.#endif
.after
"""
						c2 = """
.before
.neither
.after
"""
						fn c1, c2, {rn:false, node:false}, this
					@t "#else followed by #elseif", exceptionMessage:"line=6: depth=1 name=rn: #elseif following #else", ->
						c1 = """
.before
.#if rn
.this is rn
.#else
.neither
.#elseif node
.this is node
.#endif
.after
"""
						fn c1, "", {rn:true, node:true}, this
					@t "nested if: env=node", ->
						c1 = """
.before
.#if rn
.this is rn
.#else
.this is NOT rn
.#if node
.this is node
.#else
.this is NOT node
.#endif
.#endif
.after
"""
						c2 = """
.before
.this is NOT rn
.this is node
.after
"""
						fn c1, c2, {node:true}, this
					@t "nested if: both false", ->
						c1 = """
.before
.#if rn
.this is rn
.#else
.this is NOT rn
.#if node
.this is node
.#else
.this is NOT node
.#endif
.#endif
.after
"""
						c2 = """
.before
.this is NOT rn
.this is NOT node
.after
"""
						fn c1, c2, {}, this
					@t "nested if: breaks", ->
						c1 = """
.before
.#if rn
.this is rn
.#else
.this is NOT rn
.#if node
.this is node
.#else
.this is NOT node
.#endif
.#endif
.after
"""
						c2 = """
.before
.this is rn
.after
"""
						fn c1, c2, {rn:true}, this
					@t "double #if", ->
						c1 = """
.before
.#if rn
.#if node
.this is node
.#else
.this is NOT node
.#endif
.between
.#endif
.after
"""
						c2 = """
.before
.this is NOT node
.between
.after
"""
						fn c1, c2, {rn:true, node:false}, this
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
					@t "#endif missing", exceptionMessage:"line=6 #endif missing: \"rn\"", ->
						c1 = """
.before
.#if rn
.this is rn
.#else
.this is NOT rn
"""
						fn c1, "", {}, this
					@t "#endif missing (nested)", exceptionMessage:"line=8 #endif missing: \"rn\"", ->
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
					@t "unknown name", exceptionMessage:"line=1: depth=1 name=Michelle: unknown", ->
						c1 = """
.#if Michelle
.inside
.#endif
"""
						fn c1, "", {}, this
		)).run()
#endif

	process: process