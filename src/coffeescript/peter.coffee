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

	name = null

	arg = (line) ->
		tokens = line.split ' '
#		log "arg: #{tokens[1]}"
		tokens[1]

	req =
		bGo: true

	lines = code.split '\n'
	for line,i in lines
#		line = line.replace /Charles/, 'Christmas'

		switch
			when line[0..2] is "#if"
#				log "IF: line=#{line}: #{req.bGo}"

				# save current requirements for later
				stack.push req

				# clone otherwise side offect of messing with requirements object just saved
				req = Object.assign {}, req

				# the default is that this #if section is DEAD.  BUT, if bGo is true, then not dead: we need to flip when it else
				req.bFlipOnElse = false
				if req.bGo
					req.bFlipOnElse = true

					name = arg line

					# only go if this target is one of the environments
					req.bGo = !!ENV[name]
#					log "IF: name=#{name} bGo=#{req.bGo}"
			when line[0..4] is "#else"
				if req.bFlipOnElse
					# we're alive, so flip... whatever the logic was, now it's the opposite
#					log "flipping"
					req.bGo = ! req.bGo
			when line[0..5] is "#endif"
				req = stack.pop()
			else
				a.push line if req.bGo
	a.join '\n'








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
					@t "if: env=rn", ->
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
					@T "nested if: env=emily", ->
						c1 = """
before
#if rn
this is rn
#else
this is NOT rn
#if emily
this is emily
#else
this is NOT emily
#endif
#endif
after
"""
						c2 = """
before
this is NOT rn
this is emily
after
"""
						fn c1, c2, {emily:true}, this
		)).run()
#endif

	process: process