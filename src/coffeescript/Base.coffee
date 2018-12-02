###
Base - Superclass of all classes					*** PROJECT AGNOSTIC ***


EXTENDS: Object


DESCRIPTION



FEATURES
-


NOTES
-


TODOs
- make log functions non-enumerable?
- @cl 	class log
- inject all trace classes: @log @C, ...
- put identity in client trace


abbreviated versions:
@l
@lc
@le

@j = JSON
@d = deep
@s = silent

@log "tom", "-j", o
@log "tom, @j, o
@log "tom", @j o,

@log "these: @a, @b"
@log "@: a,b,c,d"		dumps all of them


r=reject, rj=reject, s=success, f=failure
resolve		ff		r			s
reject		rj		rj			f

KNOWN BUGS:
-
###





O = require './O'
trace = require './trace'
util = require './Util'
V = require './V'





#DUP
CAP = (s) ->
	if s.length
		s.charAt(0).toUpperCase() + s.slice(1)
	else
		""


m_stopMap = {}
m_openMap = new Map()


module.exports = class Base
#if ut
	@s_ut: ->
		UT = require './ut'

		(new (class BaseUT extends UT
			run: ->
				@t "log", (ut) ->
					if trace.HUMAN
						@log "standard log string"
						#						console.log "****************************************"
						@log {log:"some object"}
				#						@log "string", a:"object",pi:3.14159
				@t "logg on/off", (ut) ->
					@logg false, "SHOW-NO"
					if trace.HUMAN
						@logg true, "SHOW-YES"
				@t "logg object", (ut) ->
					if trace.HUMAN
						@logg true, "string", a:"object",pi:3.14159
				@_t "logX with omitted string", ->
					if trace.HUMAN
						@logCatch {logCatch:"some object"}
						@logError {logError:"some object"}
		)).run()
#endif




	constructor: ->
#		@log "Base: #{@constructor.name}"
		@__CLASS_NAME = @constructor.name
#		@__CLASS_NAME2 = "222"
		@["@who"] = "class #{@__CLASS_NAME}"

#		for pn in ["","Assert","Catch","Error","Fatal","Info","Silent","Transient","Warning"]
##			console.log "*** #{pn}"
##			this[pn] = (s, v, opt) =>		util.logBase @__CLASS_NAME, "#{pn}: #{s}", v, opt
##			this[pn] = do (pn) -> (s, v, opt) =>		util.logBase @__CLASS_NAME, "#{pn}: #{s}", v, opt
#			this["log#{CAP pn}"] = do (pn) => =>
#				console.log "LEN=" + arguments.length
#				O.LOG arguments
#				a = Array.prototype.slice.call arguments
#				O.LOG a
#				switch a.length
#					when 0
#						console.log "when 0"
#						util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME]
#					when 1
#						console.log "when 1"
#						util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME, "#{pn.toUpperCase()}: #{a[0]}"]
#					else
#						console.log "when N"
#						util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME, "#{pn.toUpperCase()}: #{a[0]}", a[1]...]
#				util.abort()
##		O.LOG this
#
##		@logTransient()
#		@logTransient "tr"
#		@logTransient "tr", {a:"b"}
#		@logTransient "tr", {a:"b"}, "c"
#		util.abort()

	
	AT_BASE: ->


	abort: (msg) -> util.abort msg

	#TODO: add additional parameters
	assert: (b, msg) ->
		unless b
			throw Error("ASSERTION FAILURE#{if msg then ": #{msg}" else ""}", @__CLASS_NAME)

	#DUP
	log: => util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME, arguments...]


	#TODO: repeat pattern above
	logAssert: (s, o, opt) =>		util.logBase @__CLASS_NAME, "ASSERT: #{s}", o, opt

	logCatch: (s, o, opt) =>
#		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
		util.logBase @__CLASS_NAME, "CATCH: #{s}", o, opt
#		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
#		throw new Error "WHY?"			#WRONG: doesn't give correct stacktrace
#		process.exit 1
	ex: (ex) =>		#RECENT
#		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
		util.logBase @__CLASS_NAME, "ex:", ex
		#		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
		process.exit 1
	CAT: (ex) =>		#RECENT
#		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
		util.logBase @__CLASS_NAME, "CAT:", ex
		#		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
		process.exit 1		

	#TODO: allow s optional
	logError: (s, o, opt) =>
		util.logBase @__CLASS_NAME, "ERROR: #{s}", o, opt
#if node
		process.exit 1			#RECENT
#endif

	logFatal: (s, o, opt) =>
		util.logBase @__CLASS_NAME, "FATAL: #{s}:", o, opt
#if node
		process.exit 1
#endif

	logInfo: (s, o, opt) =>			util.logBase @__CLASS_NAME, "INFO: #{s}", o, opt

	logSilent: (s, o, opt) =>		util.logBase @__CLASS_NAME, "SILENT: #{s}", o, bVisible:false	#H: needs to merge options	#R: SILENT

	logTransient: (s, o, opt) =>	util.logBase @__CLASS_NAME, "TRANSIENT: #{s}", o, opt

	logWarning: (s, o, opt) =>
		if trace.WARNINGS
			util.logBase @__CLASS_NAME, "WARNING: #{s}", o, opt
#			util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME, "WARNING", arguments...]







#H: since this then just try this!
	@_log: (s) -> util.logBase "Base(static)", s



	@logOpenMap: ->
		if m_openMap.size
			@_log "^|||	m_openMap.size=#{m_openMap.size}"

			now = Date.now()

			dump = (k,rec) =>
				@_log "^|||	\"#{rec.moniker}\" open for #{now - rec.msOpen}ms"

			m_openMap.forEach (v,k) =>
				dump k, v

			doNotRemoveThis = true
		else
			@_log "^|||	logOpenMap: nothing left open"



	@auditEnsureClosed: ->
#		console.log "^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{m_openMap.size}"

		if m_openMap.size
			Base.logOpenMap()
			throw new Error "auditEnsureClosed: NOT ALL CLOSED!!!"



	auditOpen: (moniker) ->
		throw new Error "only pass one argument" unless arguments.length is 1

		if m_openMap.get this
			Base.logOpenMap()
			@throw new Error "auditOpen: #{moniker}: already open"

		m_openMap.set this,
			moniker: moniker
			msOpen: Date.now()

		@logg trace.AUDIT, "auditOpen #{moniker}: count=#{m_openMap.size}"



	auditClose: (moniker) ->
		unless rec = m_openMap.get this
			Base.logOpenMap()
			@throw new Error "auditClose #1: NOT IN m_openMap!!!"

		if moniker isnt rec.moniker
			throw new Error "monikers don't match: #{rec.moniker} vs #{moniker}"

		if m_openMap.delete this
			@logg trace.AUDIT, "auditClose #{moniker}: count=#{m_openMap.size}"
		else
			@throw "auditClose #{moniker} #2: NOT IN m_openMap!!!"

		

	E: (code) ->
		throw new Error 501			# not implemented



	logg: (b, s, o, opt) =>
#		console.log "b=#{b} typeof=#{typeof b}"

		if !!b
#			console.log "enabled"
			a = Array.prototype.slice.call arguments
			if @mn
				a[1] = "{#{@mn}} #{a[1]}"
#			O.LOG a
			a.splice 0, 1
			util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME, a...]
#		else
#			console.log "disabled"




	m: (@mn) ->
#		@log "m: #{@mn}"

		

	@openCntGet: -> m_openMap.size
		


	@openMsgGet: ->
		s = "All resources closed.  "
	
		if _ = m_openMap.size
			s = "#{_} resource#{if _ is 1 then "" else "es"} left open!!!   "		

		s



	prop: (prop, desc) ->	#RECENT
		Object.defineProperty this, prop, desc



#if DEBUG
	stop: (key, cnt) ->
		unless m_stopMap[key]?
			m_stopMap[key] = 0
		if ++m_stopMap[key] is cnt
			throw new Error "STOP \"#{key}\" cnt=#{cnt}"
#endif



	tassert: (v, type) ->
#		@log type
		@assert V.type(v) is type, "tassert: expecting=#{type} got=#{V.type(v)}"



	throw: (v) -> throw new Error v