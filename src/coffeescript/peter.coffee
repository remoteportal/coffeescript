OUTPUT=1


O = require './O'
trace = require './trace'




#log = (line) -> process.stdout.write line + '\n'
log = (line) -> console.log line + '\n'

lg = (line) -> console.log line



tr = []
tr.push "abort=Context.abort"
tr.push "BB=Context.BB; GG=Context.GG; HM=Context.HM"
tr.push "kt=Context.kt; kvt=Context.kvt; vt=Context.vt"
tr.push "TYPE=Context.TYPE; Type=Context.Type; type=Context.type"
tr.push "modMap=Context.modMap"
tr.push "A=modMap.A; AP=modMap.AP; ASS=modMap.ASS; C=modMap.C; DATE=modMap.DATE; IS=modMap.IS; LL=modMap.LL; N=modMap.N; ONEW=modMap.ONEW; S=modMap.S; SP=modMap.SP; textFormat=modMap.textFormat; V=modMap.V"
tr.push "duck=V.duck; drill=ONEW.drill; json=V.json"
tr.push "IF=AP.IF;"





process = (code, ENV = {}) ->
	if OUTPUT
		lg "ENV=#{JSON.stringify ENV}"

	code = code.toString()

#	log "FILE: SRC1: #{code}\n"

	a = []

	if OUTPUT
		a.push "# process: ENV=#{JSON.stringify ENV}"
#		a.push "# cooked: "+new Date()		#GIT-NOISE

	stack = []

	arg = (line) ->
		tokens = line.split ' '
#		log "arg: #{tokens[1]}"
		tokens[1].trim()

	req =
		bAlive: true
		bChainAlive: true
		bFoundIF: false
		bFoundELSE: false


	lines = code.split '\n'

	#TODO #EASY: add ifdef end
	#TODO: add switch, elseif?
	#TODO: residue comment: //if node

	for line,lineNbr in lines
#		line = line.replace /?harles/, 'Christmas'

#		lg "------------------------------------ LINE #{lineNbr+1}: #{line}"

		#SLOW: set for EACH LINE!
		im = (name) ->
			if ENV.server
				a.push "#{name} = require './Flexbase/#{name}'"
			else if ENV.node
				a.push "#{name} = require './#{name}'"
			else if ENV.rn
				a.push "import #{name} from './#{name}';"
			else
				th "#import: neither node nor rn"

		th = (msg) ->
			env = Object.keys(ENV).sort().join ','
			start = Math.max 0, lineNbr-20
			lg "----------------------- #{msg}"
			for i in [start..lineNbr]
				lg "CONTEXT: LINE #{i+1}: #{lines[i]}"
			if OUTPUT
				throw Error "line=#{lineNbr+1}: depth=#{stack.length} ENV=#{env} stack=#{JSON.stringify stack}#{if req.name then " name=#{req.name}" else ""}: #{msg}"
			else
				throw Error "line=#{lineNbr+1}: depth=#{stack.length}#{if req.name then " name=#{req.name}" else ""}: #{msg}"
			process.exit 1

		doReq = (name, bFlipIII) ->
			req.name = name
			req.bFoundIF = true

#			"client" needs to be turned on for node for unit testing
			if req.name not in ["0","1","aws","client","daemon","dev","fuse","instrumentation","mac","node","node8","rn","ut","web","win"]
				th "unknown env target"

			# only go if this target is one of the environments
			req.bAlive = switch req.name
				when "0"
					false
				when "1"
					true
				else
					!!ENV[req.name]

			if req.bAlive
				req.bChainAlive = false			# no FURTHER action (after this #{else}if) of this chain
			# log ">>> doReq: name=#{req.name} bChainAlive=#{req.bChainAlive} bAlive=#{req.bAlive}"
		switch
			when line[0..2] is "#if"
				# log ">>> if: bChainAlive=#{req.bChainAlive} bAlive=#{req.bAlive}"

				a.push line if OUTPUT
				name = arg line

				# save current requirements for later
				stack.push req

				#CHALLENGE: why clone?  appears to break if just set req={}   !!!
				# clone (otherwise side offect of messing with requirements object just saved)
				req = Object.assign {}, req

				if req.bAlive
#					log "bAlive SETS bChainAlive"
					req.bChainAlive = true
					doReq name, true
				else
					req.bChainAlive = false

				req.bFoundELSE = false
			when line[0..6] is "#elseif"
				a.push line if OUTPUT
				if req.bFoundELSE
					th "#elseif following #else"

#				lg "elseif: bChainAlive=#{req.bChainAlive}"
				req.bAlive = false
				if req.bChainAlive
					name = arg line

					# replace requirements with new name, keep same requirement object
					doReq name
			when line[0..4] is "#else"
				a.push line if OUTPUT
				unless req.bFoundIF
					th "#else without #if"

				if req.bFoundELSE
					th "#else duplicated"
				else
					req.bFoundELSE = true

				req.bAlive = req.bChainAlive
				# log ">>> else: name=#{req.name} bChainAlive=#{req.bChainAlive} bAlive=#{req.bAlive}"
			when line[0..5] is "#endif"
				# log ">>> endif: name=#{req.name} bChainAlive=#{req.bChainAlive} bAlive=#{req.bAlive}"

				a.push line if OUTPUT
				if stack.length > 0
					# return to requirements before first #if of this current chain was encountered
					req = stack.pop()
				else
					th "#endif without #if"
			when line[0..6] is "#import"
				if req.bAlive
					a.push line if OUTPUT
					name = arg line
					if name is "UT" and !ENV.ut
						a.push "# UT import is disabled"
					else
						if ENV.server
							out = "#{name} = require './Flexbase/#{name}'"
						else if ENV.node
							out = "#{name} = require './#{name}'"
						else if ENV.rn
							out = "import #{name} from './#{name}';"
						else
							th "#import: neither node nor rn"
						a.push out
			when line[0..7] is "#IMPORT "
				if req.bAlive
					name = arg line

					a.push "# *** #IMPORT"
					a.push line

					im name

					a.push "#ORIGIN: ~/github/coffeescript/peter.coffee: tr array"
					a.push ...tr
			when line[0..8] is "#IMPORT2 "
				if req.bAlive
					name = arg line

					a.push "# *** #IMPORT2"
					a.push line

					im "Base"
					im "Context"
					im "trace"

					a.push "#ORIGIN: ~/github/coffeescript/peter.coffee: tr array"
					a.push ...tr
			when line[0..6] is "#export"
				if req.bAlive
#					a.push line if OUTPUT
					name = arg line
					if name is "UT" and !ENV.ut
						a.push "# UT import is disabled"
					else
						if ENV.node
							out = "module.exports = #{name}"
						else if ENV.rn
							out = "export default #{name};"
						else
							th "#export: neither node nor rn"
						a.push out
			when line[0..13] is "#Context2local"
				a.push "#Context2local"
				a.push "#ORIGIN: ~/github/coffeescript/peter.coffee: tr array"
				a.push ...tr
			else
#				console.log "@@@@@@@@@@ #{req.bAlive} => #{line}"

				if req.bAlive
					a.push PROC line, ENV

	if req.bFoundIF
#		throw new Error "line=#{lineNbr+1} #endif missing: #{JSON.stringify stack}"
#		throw new Error "line=#{lineNbr+1} #endif missing: #{JSON.stringify stack.forEach((o) -> o.name)}"
		throw new Error "line=#{lineNbr+1} #endif missing: \"#{req.name}\""

	if 0		#POP
		for line,lineNbr in a
			lg "AFTER: LINE #{lineNbr+1}: #{line}"

#	"# IF-COFFEE: ENV=#{JSON.stringify ENV}\n" + a.join '\n'
	a.join '\n'



PROC = (line, ENV, spath) ->
#	console.log "PROC: #{JSON.stringify ENV}:#{line} "

#	if line.length is 0
#		if ENV.rn
#			line = "#DO_NOT_EDIT"
#	else
	if line.length > 0
		if line.includes '#'
			line = line.replace /\#RECENT.*/g, ""
			line = line.replace /\#TODO.*/g, ""
			line = line.replace /\#PREV.*/g, ""
			line = line.replace /\#HERE.*/g, ""

	line

#	if line.includes "?"
#		line	#+ "!"
#	else
#		line



module.exports =
#if ut
	s_ut: (_OUTPUT) ->
		OUTPUT = _OUTPUT
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
.rn
.#elseif node
.node
.#else
.else
.#endif
.after
"""
						c2 = """
.before
.rn
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
.rn
.#if node
.node
.#else
.NOT node
.#endif
.between
.#endif
.after
"""
						c2 = """
.before
.rn
.NOT node
.between
.after
"""
						fn c1, c2, {rn:true, node:false}, this
					@t "double #if address real issue", ->
						c1 = """
.before
.#if ut
.ut
.#if node
.ut node
.#elseif rn
.ut !node rn
.#endif
.between
.#endif
.after
"""
						c2 = """
.before
.after
"""
						fn c1, c2, {ut:false, node:false, rn:true}, this
					@t "double #if: just added: make sure not covered by another test", ->
						c1 = """
.before
.#if ut
.ut
.#if node
.ut node
.#elseif rn
.ut !node rn
.#endif
#else
.ut else
.#endif
.after
"""
						c2 = """
.before
.ut else
.after
"""
						fn c1, c2, {ut:false, node:false, rn:true}, this
					@t "NEG: #else", exceptionMessage:"line=2: depth=0: #else without #if", ->
						c1 = """
.abc
.#else
.def
"""
						fn c1, "", {rn:true}, this
					@t "NEG: #endif", exceptionMessage:"line=2: depth=0: #endif without #if", ->
						c1 = """
.abc
.#endif
.def
"""
						fn c1, "", {rn:true}, this
					@t "NEG: #else duplicated", exceptionMessage:"line=6: depth=1 name=rn: #else duplicated", ->
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
					@t "NEG: #endif missing", exceptionMessage:"line=6 #endif missing: \"rn\"", ->
						c1 = """
.before
.#if rn
.this is rn
.#else
.this is NOT rn
"""
						fn c1, "", {}, this
					@t "NEG: #endif missing (nested)", exceptionMessage:"line=8 #endif missing: \"rn\"", ->
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
					@t "NEG: unknown name", exceptionMessage:"line=1: depth=1 name=Michelle: unknown", ->
						c1 = """
.#if Michelle
.inside
.#endif
"""
						fn c1, "", {}, this



#
##if node
#			trace = require './trace'
#			V = require './V'
#			O = require './O'
##else
#			import trace from './trace';
#			import V from './V';
#			import O from './O';
##endif
#
##HERE
##TODO
##import trace
##import V
##import O
#
##if node
#			module.exports = EXPORTED
##else
#			export default EXPORTED
##endif
#

					@t "#import #export (node)", ->
						c1 = """
.#import V
.#export EXPORTED
"""
						c2 = """
V = require './V'
module.exports = EXPORTED
"""
						fn c1, c2, {node:true}, this
					@t "#import #export (rn)", ->
						c1 = """
.#import V
.#export EXPORTED
"""
						c2 = """
import V from './V';
export default EXPORTED;
"""
						fn c1, c2, {rn:true}, this
					@_t "??", ->
						c1 = """
console.log "#{true ? "true" : "false"} and that is it!"
"""
						c2 = """
HELP
"""
						fn c1, c2, {}, this
					@s "PROC", ->
						@_t "PROC", ->
							@eq PROC("abc def ? hello there : test monkey",{}), "hello"
						@t "#RECENT", ->
							@eq PROC("abc#RECENTdef",{}), "abc"
						@_t "rn empty line", ->
							@eq PROC("",{rn:true}), "#DO_NOT_EDIT"

		)).run()
#endif

	process: process