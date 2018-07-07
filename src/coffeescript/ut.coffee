INFINITE_LOOP_DETECTION_ITERATIONS = 100
B_FAIL_FAST = false
T = true


###			**MASTER**
YAJUT - Yet Another Javascript Unit Test


USAGE:
yajut						run current configuration
yajut conffile				run configuration stored as JSON in text file
yajut list					list all tests in directory
yajut purgelogs				forceably purge all previous log directories and files without user confirmation
yajut resetstats			forceably reset all test statistics without user confirmation
yajut -k keyword			run all tests matching keyword
yajut -r					re-run all failed tests from the exact preceeding run
yajut -s conffile			save current code-specified configuration into confifile for manual editing or re-use later



EXTENDS: Base



DESCRIPTION:
The goal of JAJUT is to be absolutely the least-friction most-terse easiest to use JS unit test system.



Promise-based, hierarchical test, minimalist and least-boilerplate, inline with source code unit test framework.

- (ut) -> vs @utMethod: the value of 'ut' parameter is that:
    - @ form is shorter
    - but using ut: a test can use closure not fat arrows (=>) to access ut properties and methods
    - but using ut: if inside a overridden child method of a sub-class: onReceive where 'this' context is the object not the ut



FEATURES
-


ERRORS:
UT001 Unknown test option
UT002 Unknown mType=#


TODOs
- ut() to fulfill async?
- force to run all tests
- create UT and UTRunner as they *are* different, right?
- decorate section (s)
- log EVERY run to new timestamp directory with tests ran in the directory name... store ALL data
	- two files: currently enabled trace and ALL TRACE
	- auto-zip at end
	- directory: 2018-05-01 6m tot=89 P_88 F_1 3-TestClient,Store,DeathStar TR=UT_TEST_POST_ONE_LINER,ID_TRANSLATE.zip
		traceSelected.txt
		traceAll.txt
		src/...
- if run all TESTS report how many are disabled _
- change ut to t
- target=NODE_SERVER command line switch
- put cleanup in opts  but that means @client and @server or implement our own timeout mechanism, again, inside here:
- onPost -> @testHub.directoryRemoveRecursiveForce()
- actually:  @testHub.directoryGetTempInstanceSpace
- test auto-discovery so don't need to explicity list in tests.coffee
- add @rnd() functions
- add milepost functionality
- validate system-level options parameter names
- validate per-unit test on-the-fly options for mispellings
- parallel mode: run as many tests in parallel as possible for speed.  If two can't run at same time then specify a mutex keyword {mutex:"db"}  but if create separate databases then shouldn't be a problem
- @defined x
- EXCEPTION to check the actual type of exception... many false positives/negatives unless do THAT
- @db_log (snapshot)
- @db_diff	do snapshot into delta arrays
- only create tables once per section, and is run een if only a single test override in place... not sure how to pull this off.  @s -> if @testing ...
- auto-teardown: you register setup things and what to do with them... if anything goes wrong they are torn down
- write test results in JSON file so that can do "query" like "when was the last time this test passed?"
- children ndoes that "build" to the current overridden child node... preceeding steps...really great idea!
- designate test as a negative test... @tn... @n...  @an...?
- @s {mutex: "ut"}           meaning, don't run this section concurrently with other ut mutex test
- run all asynch tests at same time concurrently
- classify tests: positive, negative, boundary, stress, unspecified, etc.
- run all tests < or > than so many milliseconds
- node -cat  show all unit tests
- node -grep xxx   grep all matching tests
- capitalize section ("S") overrides to run entire sections
- purposeful 1000ms delay between tests to let things settle
- count the number of disabled tests
- include string diff report functions to make it really easy to ascertain why @eq fails
#EASY: dump all possible test options... in grid with S T A section/test/asynch columns in front, option, desc, and example
#EASY: new option def:
    @t "some test",
			def:
				em: "Deanna is beautiful"
				b: "b-value"
			exceptionMessage: @em			HOW DO THIS?
		, ->
			throw @em
    should be readable by ut.a, @a, and other parameters.  Ensure don't stomp on system



KNOWN BUGS:
-
###





#GITHUB: minimize dependencies!
Base = require './Base'
O = require './O'
S = require './S'
trace = require './trace'
util = require './Util'
V = require './V'








bHappy = true
g_timer = null
path = ''
testStack = []
testList = []
testIndex = null
bRunning = null
iterations = null
testListSaved = null
t_depth = 0

pass = fail = 0
bRan = false

msStart = null

TESTNBR = null



bag = Object.create
	clear: ->
		for k of bag
			unless k is "clear"
				delete bag[k]
		return


#PATTERN: target is function
target = (cmdUNUSED_TODO) ->
	if trace.UT_BAG_DUMP
	#	console.log "HI: cmd=#{cmdUNUSED_TODO}"
		sans = Object.assign {}, bag
		delete sans.clear

		O.LOG sans		#NOT-DEBUG

		if _=O.CNT_OWN sans
			console.log "*** bag: #{_} propert#{if _ is 1 then "y" else "ies"}:"
			for k,v of sans
				if typeof v is "object"
					console.log "*** bag: #{k} ="
					O.LOG v
				else
					console.log "*** bag: #{k} = #{V.DUMP v}"
		else
			console.log "*** bag: empty"
		return


#PATTERN: target isn't actually proxy target
handler =	# "traps"
	get: (target, pn) ->
#		console.log "read from bag: #{pn} => #{bag[pn]}"
		bag[pn]

	set: (target, pn, pv) ->
		console.log "proxy: set: #{pn}=#{pv} <#{typeof pv}>"										if trace.UT_BAG_SET
		throw "clear is not appropriate" if pn is "clear"
		bag[pn] = pv


proxyBag = new Proxy target, handler


decorate = (test, fn, testThis, parent) ->
	unless fn
		console.error "#{test.tn}: function body is required"
#if node
		process.exit 1
#endif

#	me2 = Object.create testThis

	decorateJustObject test, testThis, parent

#	console.log "*** bRunToCompletion=#{testThis.bRunToCompletion}"

	fn2 = fn.bind testThis




#REN me2 to testThis
decorateJustObject = (test, me2, parent) ->
	me2.t = T		# true	#TRACE

	me2.mState = @STATE_SETUP
	
	me2.test = test			#H

	me2.tn = test.tn

	me2.opts = test.opts

	me2.bag = proxyBag

	me2.context		= "CONTEXT set in decorateJustObject"

#	me2.parent = parent		#H

#	me2.one = "#{test.cname}/#{test.tn}"


	#METHODS
	me2.throw = (v) -> throw new Error v


	me2.abort = (msg) -> util.abort msg


	me2.assert = (b, msg) ->
		_ = if msg then ": #{msg}" else ""

		@logSilent "assert: b=#{b}#{_}"

		if b
			pass++
		else
			@log "ASSERTION FAILURE#{_}"
			fail++
			util.abort "B_FAIL_FAST" if B_FAIL_FAST

		b


	me2.defined = (v, msg) ->
		_ = if msg then ": #{msg}" else ""

		@logSilent "defined: b=#{b}#{_}"

		b = v?

		if b
#			console.log "defined"
			pass++
		else
			@log "DEFINED FAILURE#{_}"

			#TODO: put in subroutine
			fail++
			util.abort "B_FAIL_FAST" if B_FAIL_FAST

		b


	me2.delay = (ms) ->
		to =
			ms: ms
			msActual: null
			msBeg: Date.now()
			msEnd: null

		new Promise (resolve) =>
			@logg trace.DELAY, "BEG: delay #{ms}"

			setTimeout =>
					to.msEnd = Date.now()
					to.msActual = to.msEnd - to.msBeg
					@logg trace.DELAY_END, "END: delay #{ms} ********************************", to
					resolve to
				,
					ms


	#TODO: create V.EQ routine
	#TODO: two arguments plus string identifier
	#REN: me2 is terrible name!
	me2.eq = ->
		bEQ = true

		@logSilent "inside eq: arguments.length=#{arguments.length}"

#		@log "ut: bRunToCompletion=#{@bRunToCompletion}"

		if arguments.length >= 2
			@logSilent "arguments passed: arguments.length=#{arguments.length}"


			# both undefined?
			#TODO: check all args
			if !(arguments[0]?) and !(arguments[1]?)
				@logSilent "both undefined"
				return


			# typeS
#			console.log "---CHECK typeS---"
			bEQ = true
			_ = V.type arguments[0]
#			process.exit 1
			for i in [0..arguments.length-1]
#				@log "arg#{i}: #{V.PAIR arguments[i]} #{typeof arguments[i]}"
#				@log "arg#{i}: #{V.PAIR arguments[i]} #{typeof arguments[i]} --> #{S.DUMP V.type(arguments[i]), true}"


#				@log "#{_}-#{V.type arguments[i]}"
				unless _ is V.type arguments[i]
					bEQ = false
#					console.log "TTTTTTTTTT"
#			console.log "aaa"

			unless bEQ
				s = "@eq types violation:\n"
				for i in [0..arguments.length-1]
					s += "> arg#{i}: #{V.type arguments[i]}\n"
#				@log "ut2: bRunToCompletion=#{@bRunToCompletion}"
				@logError s


			if bEQ
				# VALUES
#				console.log "---CHECK VALUES---"
				bEQ = true
				_ = arguments[0]
				for i in [0..arguments.length-1]
					@logSilent "arg#{i}: #{V.PAIR arguments[i]} #{typeof arguments[i]}"

					#WARNING: old code used to sometime hang node; it was very bizarre
					# unless _ is arguments[i]	#H
					#NOTE #REVELATION: "peter" NOT-EQUAL-TO new String "peter"
					# so force to string first!!!!!!!!!!!!!
					unless ""+_ is ""+arguments[i]
						bEQ = false
#						console.log "i=#{i}: #{_}-#{arguments[i]}"

				unless bEQ
					@logError "@eq values violation!\n" + S.COMPARE_REPORT arguments[0], arguments[1]
		else
			throw new Error "eq: must pass at least two arguments"

		if bEQ
			pass++
		else
			@log "fail++"
			fail++
			util.abort "B_FAIL_FAST" if B_FAIL_FAST

		bEQ


	
	me2.eqfile_pr = (a, b) ->		#CONVENTION
		new Promise (resolve, reject) =>
			size_a = null

			util.size_pr a
			.then (size) =>
				size_a = size
				util.size_pr b
			.then (size_b) =>
				@eq size_a, size_b
				resolve()
			.catch (ex) =>
				@logCatch ex



	me2.ok = (v) ->
#		O.LOG_DRILL this, grep:"env"
#		@env.succ()		#TODO: get reference to @env and tear down resources
		@resolve v
	me2.ex = (ex) ->
		console.log "aaaaa"
		@logCatch ex
		console.log "bbbbb"
		@reject ex
		console.log "ccccc"


	me2.fail = (msg) ->
		@log "me2.fail"
		fail++
		util.abort "B_FAIL_FAST" if B_FAIL_FAST
		if msg
			@logError msg
		false		# so cal call @fail as last statement of onException, onTimeout, etc.


	me2.fatal = (msg) ->
#		console.error "fatal: #{msg}"

		clearInterval g_timer
		bHappy = false
		bRunning = false
		util.exit msg


	#DUP
	#TODO: manufacture?
	me2.log			= ->
		if trace.UT_TEST_LOG_ENABLED
			util.logBase.apply this, ["#{test.cname}/#{test.tn}", arguments...]

	me2.logError	= (s, o, opt)		->
#		console.log "logError: bRunToCompletion=#{@bRunToCompletion}"
		
		if V.type(s) isnt "string"
			o = s
			opt = o
			s = ""

		if @bRunToCompletion
			util.logBase "#{test.cname}/#{test.tn}", "ERROR: #{s}", o, opt
		else
			util.logBase "#{test.cname}/#{test.tn}", "FATAL_ERROR: #{s}", o, opt
			util.exit "logError called with @bRunToCompletion=false"
	me2.logCatch	= (s, o, opt)		->
#		console.log "ooo #{@bRunToCompletion}"

		#RECURRING-ERROR: if V.type s  isnt "string"
		#RECURRING-ERROR: if V.type(s) isnt "string"

		#TODO #SUBROUTINE
		if V.type(s) isnt "string"
#			console.log "SHIFT DOWN: V.type s => #{V.type s}"
			o = s
			opt = o
			s = ""

		if @bRunToCompletion and !B_FAIL_FAST
			util.logBase "#{test.cname}/#{test.tn}", "CATCH: #{s}", o, opt
		else
#			O.LOG "XXXXXXXXXXXXX", s, o, opt
			util.logBase "#{test.cname}/#{test.tn}", "FATAL_CATCH: #{s}", o, opt
#if node
#			console.log "ooo #{@bRunToCompletion}"
			@abort "logCatch bRunToCompletion=false"
#			throw new Error
#endif

	me2.logFatal	= (s, o, opt)		->
		if V.type(s) isnt "string"
			o = s
			opt = o
			s = ""

		util.logBase "#{test.cname}/#{test.tn}", "FATAL: #{s}", o, opt
		util.exit()

	me2.logSilent	= (s, o, opt)		-> util.logBase "#{test.cname}/#{test.tn}", s, o, bVisible:false

	me2.logTransient = (s, o, opt)		->
		if @bRunToCompletion
			util.logBase "#{test.cname}/#{test.tn}", "TRANSIENT: #{s}", o, opt
		else
			util.logBase "#{test.cname}/#{test.tn}", "FATAL_TRANSIENT: #{s}", o, opt
			util.exit "logError called with @bRunToCompletion=false"

#	me2.logWarning	= (s, o, opt)		->	util.logBase "#{test.cname}/#{test.tn}", "WARNING: #{s}", o, opt
#	me2.logWarning	= (s, o, opt)		->	util.logBase.apply this, ["#{test.cname}/#{test.tn}", "WARNING2", arguments...]
	me2.logWarning	= (s, o, opt)		->	util.logBase.apply this, ["#{test.cname}/#{test.tn}", "WARNING2", arguments...]

	me2.pass = ->
		pass++
		true			# so can call @pass() as last statement of onException, onTimeout, etc.


#	O.LOG_DRILL test.parent
#	for v in Object.getOwnPropertyNames test.parent
#		console.log "==> #{v}"
#	for k,v of test.parent
#		console.log "==> #{k}"
#		if me2[k]
#			throw "You are not allowed to define the method named '#{k}' because it clashes with a built-in property"

#	k = "alloc"
#	me2[k] = test.parent[k]

#	O.LOG "test.parent", test.common
	if test.common
		for mn in test.common
	#		console.log "==> #{mn}"
			if me2[mn]
				throw "You are not allowed to define the method named '#{mn}' because it clashes with a built-in property"
			me2[mn] = test.parent[mn]



aGenerate = (cmd) =>
	(tn, fn) ->
#		console.log "$$$$$$$$$$$$$0 #{arguments[0]}"
#		console.log "$$$$$$$$$$$$$1 #{arguments[1]}"
#		console.log "$$$$$$$$$$$$$2 #{arguments[2]}"
#		console.log "$$$$$$$$$$$$$3 #{arguments[3]}"

		if Object::toString.call(fn) is '[object Object]'
			opts = fn
			fn = arguments[2]

		unless typeof fn is "function"
			util.abort "MISSING fn"

		if bRunning and t_depth is 1
			@logFatal "NESTED t: the parent of '#{tn}' is also a test; change to 's' (section)"
		#		@log "found async: #{tn} --> #{@__CLASS_NAME}"

#		if cmd is "A"
#			O.LOG_DRILL this
#			this.alloc "peter"

#		@log "CLASS=#{@__CLASS_NAME}  TN=#{tn} ===> PATH=#{path}"
#		@log "#{@__CLASS_NAME}#{path}/#{tn}"

		#H: combine	#DUP
		testList.unshift
			bEnabled: false
			cmd: cmd
			cname: @__CLASS_NAME
			tn: tn
			fn: fn
			one: "#{@__CLASS_NAME}/#{tn}"
			opts: opts ? {}
			parent: this
			common: Object.getOwnPropertyNames(Object.getPrototypeOf(this)).filter (mn) -> mn not in ["constructor","run"]
			path: "#{@__CLASS_NAME}/#{path}/#{tn}"
#		console.log "********** aGenerate: #{path}"

#		if tn is "alloc objectInsert"
#			o = Object.getPrototypeOf this
#			a = Object.getOwnPropertyNames o
#			for pn in a
#				@log pn	#, this[pn]
#			O.LOG_DRILL o, true
#			util.abort()
#		@log "xxxxxxxxxxx", Object.getOwnPropertyNames Object.getPrototypeOf(this)


testGenerate = (cmd) =>
	(tn, fn) ->
		if Object::toString.call(fn) is '[object Object]'
			opts = fn
			fn = arguments[2]

		unless typeof fn is "function"
			util.abort "MISSING fn"

		if bRunning
			if ++t_depth is 2
				@abort "NESTED t: the parent of '#{tn}' is also a test; change to 's' (section)"
			fn()
			--t_depth
		else
#			console.log "found test: #{tn}: cmd=#{cmd}"

			testList.unshift
				bEnabled: false
				cmd: cmd
				cname: @__CLASS_NAME
				tn: tn
				fn: fn
				one: "#{@__CLASS_NAME}/#{tn}"
				opts: opts ? {}
				parent: this
				path: "#{@__CLASS_NAME}/#{path}/#{tn}"

#			console.log "********** testGenerate: #{path}"


sectionGenerate = (cmd) =>
	(tn, fn) ->
		throw 0 unless typeof tn is "string"
		throw 0 unless typeof fn is "function"

		if Object::toString.call(fn) is '[object Object]'
			opts = fn
			fn = arguments[2]

		unless typeof fn is "function"
			util.abort "MISSING fn"

		if bRunning and t_depth is 1
			util.abort "NESTED t: the parent of '#{tn}' is also a test; change to 's' (section)"

#		@log "found section: #{tn}"
		testStack.push tn

		path = testStack.join '/'
#		console.log "BEG: sectionGenerate: #{path}"

		fn.bind(this)
			one: "#{@__CLASS_NAME}/#{tn}"
			opts: opts ? {}
			parent: this	#H
			tn: tn

		testStack.pop()
		path = testStack.join '/'
#		console.log "END: sectionGenerate: #{path}"




#H: overloaded between UT runner and superclass
module.exports = class UT extends Base
	constructor: (@bRunToCompletion, @fnCallback, @opts = {}, @WORK_AROUND_UT_CLASS_NAME_OVERRIDE) ->
		super "I DO NOT UNDERSTAND WHY I CANNOT PASS @__CLASS_NAME HERE and I don't know why it works when I don't!!!"
#		console.log "UT CONSTRUCTOR IMPLICIT CALL: #{@WORK_AROUND_UT_CLASS_NAME_OVERRIDE} #{@constructor.name}"
#		@log "bRunToCompletion=#{@bRunToCompletion}"
#		O.LOG @opts
		@__OPTS = @opts	#HACK
		@__CLASS_NAME = @WORK_AROUND_UT_CLASS_NAME_OVERRIDE ? @constructor.name
		testIndex = "pre"
		bRunning = false

	NEG: 0
	PROOF: 1

	STATE_SETUP: 0
	STATE_RUN: 1
	STATE_TEARDOWN: 2



	#COMMAND: asynchronous test
	_A: (a, b, c) ->
	_a: (a, b, c) ->
	A: (a, b, c) -> aGenerate('A').bind(this) a, b, c
	a: (a, b, c) -> aGenerate('a').bind(this) a, b, c


	#COMMAND: section / directory of tests
	_S: (a, b, c) ->
	_s: (a, b, c) ->
	S: (a, b, c) -> sectionGenerate('S').bind(this) a, b, c
	s: (a, b, c) -> sectionGenerate('s').bind(this) a, b, c


	#COMMAND: synchronous test
	_T: (a, b, c) ->
	_t: (a, b, c) ->
	T: (a, b, c) -> testGenerate('T').bind(this) a, b, c
	t: (a, b, c) -> testGenerate('t').bind(this) a, b, c



	argsProcess: (a) ->
		optionList = [
				o: "-all"
				d: "force all tests to be run (ignore individual test overrides)"
			,
				o: "-grep pattern"
				d: "NOT-IMP: -l but only show matching lines"
			,
				o: "-h"
				d: "help"
			,
				o: "-l"
				d: "list all tests"
			,
				o: "-t a,b,c,..."
				d: "NOT-IMPL: trace: only turn on specified traces"
			,
				o: "-tn"
				d: "trace No: turn off all trace"
			,
				o: "-ty"
				d: "trace Yes: turn on all trace"
			,
				o: "<number>"
				d: "test number from 1 to the (number of tests)"
		]

		i = 0
		while i < a.length
			item = a[i++]

			switch item
				when "-all"
					@__OPTS.allForce = true
				when "-grep"
					pattern = a[i++]
					console.log S.autoTable(testList, {bHeader:true, grep:pattern, ignore:"bEnabled,common,fn,parent,path,one,opts"})
					process.exit 0
				when "-h"
					console.log """
node tests.js [options]

OPTIONS:#{S.autoTable(optionList, {bHeader:false})}"""
					console.log
					process.exit 1
				when "-l"
#			bEnabled: false
#			cmd: cmd
#			cname: @__CLASS_NAME
#			tn: tn
#			fn: fn
#			one: "#{@__CLASS_NAME}/#{tn}"
#			opts: opts ? {}
#			parent: this
#			common: Object.getOwnPropertyNames(Object.getPrototypeOf(this)).filter (mn) -> mn not in ["constructor","run"]
#			path: "#{@__CLASS_NAME}#{path}/#{tn}"
					console.log S.autoTable(testList, {bHeader:true, ignore:"bEnabled,common,fn,parent,path,one,opts"})
					process.exit 0
				when "-tn"
					@__OPTS.traceOverride = false
					T = false
				when "-ty"
					@__OPTS.traceOverride = true
				else
					if Number.isInteger(item * 1)
						TESTNBR = item * 1
					else
						console.error "UT: Illegal option: \"#{item}\""
						process.exit 1
		return



	next: ->
		unless bRunning
			return

#SCARY	objectThis = this
#		O.LOG objectThis
#		@abort()

		#H: is this while loop even used anymore?
		while testIndex < testList.length
			if iterations++ > INFINITE_LOOP_DETECTION_ITERATIONS
				@logFatal "infinite loop detected (stopped at #{iterations} iterations)"

			#TODO: @assert
#			@log "#{testListSaved} VS #{testList.length}"
			if testListSaved isnt testList.length
				@logFatal "testList corruption"

				
			if TESTNBR and TESTNBR isnt (testIndex+1)
				@post null, null
				return
				
			test = testList[testIndex]

			test.opts = Object.assign {}, @__OPTS, @__OPTS?.perTestOpts?[test.cname], test.opts
			delete test.opts.perTestOpts
#			O.LOG "next.opts:", test.opts

			if fail
				util.abort "something failed"

			# iter=#{iterations}
			@logg trace.UT_TEST_PRE_ONE_LINER, "================== ##{testIndex+1} #{test.path}"		# ##{testIndex+1}/#{testList.length} #{test.cname} #{test.cmd}:#{test.tn}#{if trace.DETAIL then ": path=#{test.path}" else ""}"

			if test.bRun
				@logFatal "already run!"
			else
				test.bRun = true

			test.msBeg = Date.now()

			#EXPERIMENTAL
			#SCARY
			#						O.LOG test.parent
			#						@abort()
			testThis = Object.assign {}, test.parent

			switch test.cmd
				when 'a', 'A'
					handle = null

					prNOT_USED = new Promise (resolve, reject) =>
#						@log "ASYNC #{test.cname} #{test.tn} PATH=#{test.path}"	# type=#{typeof test.fn} fn=#{test.fn}"

						testThis.resolve = resolve
						testThis.reject = reject

						#H: not multi-threaded!
						testThis.resolve = resolve
						testThis.reject = reject

						testThis.testIndex = testThis.testIndex = testIndex
						@fnCallback? "pre", "a", testThis, @__OPTS
						#TODO: return Promise
						#TODO: do post
						
						fn2 = decorate test, test.fn, testThis, this

#						decorateJustObject test, testThis, this
						
#						O.LOG testThis
						ms = if testThis.opts.hang then 2147483647 else testThis.opts.timeout
						# @log "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ setting timer: #{ms}ms"
						handle = setTimeout =>
								bExpectTimeout = false

								if test.opts.onTimeout?
									fnBoundObjectThis = decorate test, test.opts.onTimeout, testThis, this
									bExpectTimeout = fnBoundObjectThis testThis
#									@log "a: bExpectTimeout=#{bExpectTimeout}"

								if bExpectTimeout or test.opts.expect is "TIMEOUT"
									resolve()
									return

								@log "[[#{test.path}]] TIMEOUT: ut.{resolve,reject} not called within #{ms}ms in asynch test"
								fail++
								util.abort "B_FAIL_FAST" if B_FAIL_FAST
								reject "TIMEOUT"
							,
								ms

						try
							rv = fn2 testThis

#EXPERIMENTAL
#							@log "rv=#{Object::toString.call rv}"
#							if Object::toString.call(rv) is "[object Promise]"
##								@log "interpretting Promise"
#								rv.then (resolved) =>
#									@log "FOUND RESOLVED PROMISE"

#									#DUP: with below... put in subroutine
#									if resolved
#										@logg trace.UT_RESOLVED, "#{test.one} result", resolved
#									clearTimeout handle
#									pass++
#
#									if fail and !@bRunToCompletion
#										@log "if fail and !@bRunToCompletion"
#										util.abort "fail=#{fail}"
#										process.exit 1
#
#									@post test, "a-then: #{test.cname}/#{test.tn}"
#								.catch (ex) =>
#									@logCatch "CATCH", ex
						catch ex
							clearTimeout handle
							#YES_CODE_PATH
							@logCatch "async exception in '#{test.cname}/#{test.tn}'", ex
							unless @bRunToCompletion
								process.exit 1
					.then (resolved) =>
						if resolved
							@logg trace.UT_RESOLVED, "#{test.one} result", resolved
						clearTimeout handle
						pass++

						if fail and !@bRunToCompletion
							@log "if fail and !@bRunToCompletion"
							util.abort "fail=#{fail}"
							process.exit 1

						@post test, "a-then: #{test.cname}/#{test.tn}"
					.catch (ex) =>
						@log "catch: REJECT CALLED DURING ASYNC", ex

						clearTimeout handle
#						if ex is "TIMEOUT" and test.opts.expect is "TIMEOUT"
#							pass++
#							@post test, "a-expect-TIMEOUT"
						unless ex is "TIMEOUT"
							@log "fail++ NOT TIMEOUT"
							fail++
							util.abort "B_FAIL_FAST" if B_FAIL_FAST
							@logCatch "a-cmd", ex

						unless @bRunToCompletion
							process.exit 1		#H

						@post test, "a-catch"
					return		#IMPORTANT
				when 't', 'T'
					# @log "RUNNING #{test.tn} PATH=#{test.path} pass=#{pass} fail=#{fail}"#" #{test.fn}"
					passSave = pass			#TODO: do for asynch, too
					failSave = fail

					try
						#TODO: pass in node arguments, too

						if ++t_depth is 2
							@logFatal "[#{test.path}] nested tests"

						testThis.testIndex = testThis.testIndex = testIndex
						#TODO: also have coffeeScript scan for documentation if -doc flag passed or whatever
						@fnCallback? "pre", "t", testThis, @__OPTS

#						O.LOG "objectThis", objectThis

						fnBoundObjectThis = decorate test, test.fn, testThis, this
						rv = fnBoundObjectThis testThis
						if Object::toString.call(rv) is "[object Promise]"
							@logFatal "promise returned from synchronous: wrong test command: use async instead of synchronous"

#						@log "back from test"

						if fail > failSave and test.opts.expect is "ERROR"
#							@log "RESTORE: expect=ERROR: eliminate: pass=#{pass} fail=#{fail}"
							pass = passSave
							fail = failSave

						@fnCallback? "post", "t", testThis, @__OPTS

#						@log "say something meaningful here"										if trace.UT_TEST_POST_ONE_LINER	#TODO

						if test.opts.expect is "EXCEPTION"
							# shouldn't be here
							@logError "expected exception but didn't get one!!!"
							
							#TODO: general failure routine
							fail++
							util.abort "B_FAIL_FAST" if B_FAIL_FAST
						else if pass is passSave
							# implicit pass
							pass++

						--t_depth
						@post test, "t"		#WARNING: could cause very deep stack
					catch ex
#						@log "t-catch ------", ex		#URGENT #TODO: move the try/catch exactly around the t-function call!

						--t_depth

						bWasException = true

						bExpectException = false
						bRestore = false

						#TODO: put stuff in common routine
						if test.opts.onException?
							fnBoundObjectThis = decorate test, test.opts.onException, testThis, this
							bExpectException = fnBoundObjectThis testThis
#							@log "t: bExpectException=#{bExpectException}"

						if bExpectException or test.opts.expect is "EXCEPTION"
							bWasException = false
							bRestore = true
							if test.opts.exceptionMessage?
#								@log "ex", ex
#								@log ""+ex
								if ex.message isnt _= test.opts.exceptionMessage		#BRITTLE?
									@log "WRONG EXCEPTION MESSAGE!"
									@log '^' + S.COMPARE_REPORT ex.message, _, preamble:"ex.message\n\ntest.opts.exceptionMessage"
									bWasException = true

						if bWasException
							fail++
							util.abort "B_FAIL_FAST" if B_FAIL_FAST
							@logCatch "[#{test.path}] t-handler", ex
						else
							if bRestore
								@log "restore: eliminate: pass=#{pass} fail=#{fail}"
								pass = passSave
								fail = failSave			# restore fail's from eq failures

							if pass is passSave
								# implicit pass
								pass++

						@post test, "t-catch"
					return
				when 's', 'S'
					@post null, "s"
					return
				else
					@logFatal "unknown cmd=#{test.cmd}"
#			@log "bottom of while"
#		@log "UT-DONE ##{testIndex}/#{testList.length}"



	post: (test, who) ->
#		throw new Error "WTF?"

		if test
			test.msEnd = Date.now()
			test.msDur = test.msEnd - test.msBeg
			
			@logg trace.UT_DUR, "#{test.msDur}: #{test.path}"

#		@log "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ post: who=#{who} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


		if Base.openCntGet()
			Base.logOpenMap()
			util.abort "INTERMEDIATE RESOURCES LEFT OPEN!"

		if ++testIndex is testList.length
#			@log "UT-DONE: who=#{who}"
			bRunning = false
		else
#			@log "post: next: who=#{who}"
			@next()
#			if g_timer
#				@next()
#			else
#				console.error "g_timer is null"



	run: ->			#H: UT should know NOTHING about "TestHub"
		@["@who"] = "UNIT TEST RUNNER"

		@argsProcess process.argv.slice 2

		@fnCallback? "init", "UT", null, @__OPTS

		@stackReset()

#		@log "run"
#		O.LOG_DRILL this, true

		mTypeCtrList = [0,0]
		for test in testList
			if opts = test.opts
#				@log "opts", opts

				if opts.exceptionMessage and !opts.expect?
					opts.expect = "EXCEPTION"

				cmds = ["desc","exceptionMessage", "expect","hang","human","internet","mType","onError","onException","onTimeout","SO", "RUNTIME_SECS", "timeout", "url", "USER_CNT"]
				cmds.push '_' + cmd for cmd in cmds
				for k of opts
					unless k in cmds
						@logFatal "[[#{test.path}]] UT001 Unknown test option: '#{k}'", opts

				if (opts.onTimeout or opts.timeout) and test.cmd not in ["_a","a","_A","A"]
					@logFatal "[[#{test.path}]] asynch opt not allowed with '#{test.cmd}' cmd", opts

				if opts.mType?
#					@log "********", opts.mType
					if 0 <= opts.mType <= 1
						mTypeCtrList[opts.mType]++
					else
						@logFatal "[[#{test.path}]] UT002 Unknown mType=#{opts.mType}", opts
		summary = "[NEG=#{mTypeCtrList[0]} PROOF=#{mTypeCtrList[1]}]"


		new Promise (resolve, reject) =>
			throw 0 if bRunning
			throw 0 if bRan
			bRan = true
			msStart = Date.now()

#			@log "run: test count=#{testList.length}"

			if testList.length > 0
				testList.reverse()

				testIndex = 0
				while testIndex < testList.length
					test = testList[testIndex]
	#				@log "pre: ##{testIndex} #{test.cmd}:#{test.tn}: #{test.path}"
					testIndex++

				testIndex = 0
				bRunning = true
				iterations = 0

				bFoundOverride = false
				testList.forEach (test) =>
					if /^[A-Z]/.test test.cmd
#						@log "found ut override: #{test.tn}"
						test.bEnabled = true
						bFoundOverride = true

				if @__OPTS.allForce
					bFoundOverride = false

				testListSaved = testList.length

				if bFoundOverride
					testList = testList.filter (test) => test.bEnabled
#					console.log "FIRST"
#					@log "test", a:"a", false
#					@log "test", a:"a", true
#					@log "ONE", "TWO", "THREE"
#					util.abort "NOW"

#					fn = (a, b) ->
#						O.LOG arguments
#					fn "a", "b"
					@log "#{summary} Found #{testListSaved} test#{if testListSaved is 1 then "" else "s"} with #{testList.length} override#{if testList.length is 1 then "" else "s"}"

				if testList.length > 0
					testListSaved = testList.length

					@next()

					#HACK: utilize this timer to keep node running until all tests have completed
					g_timer = setInterval =>
							unless bRunning
								if bHappy
									secs = Math.ceil((Date.now() - msStart) / 1000)
									@log "======================================================"
									@log "#{Base.openMsgGet()}  All unit tests completed: [#{secs} second#{if secs is 1 then "" else "s"}] total=#{pass+fail}: #{unless fail then "PASS" else "pass"}=#{pass} #{if fail then "FAIL" else "fail"}=#{fail}"
									clearInterval g_timer

									if Base.openCntGet()
										#PARAMS: eventName, primative, objectThis
										@fnCallback? "left-open", "ut", this

									if fail
										resolve "[#{secs}s] fail=#{fail}"
									else
#TODO: "Tests longer than truems:"		is it getting corrupted somewhere?
										if trace.TRACE_DURATION_REPORT and testList.length
											s = "\nTests longer than #{trace.TRACE_DURATION_MIN_MS}ms:"

											testList.sort (a, b) -> if a.msDur > b.msDur then -1 else 1

											for i in [0..testList.length-1]
												test = testList[i]

												if test.msDur > trace.TRACE_DURATION_MIN_MS
													if s
														console.log s
														s = null

													console.log "> #{test.msDur}: #{test.tn}     #{test.path}"

										resolve "[#{secs}s] pass=#{pass}"
						,
							100


	stackReset: ->
		testStack.length = 0
		path = ''



	@s_ut: -> new UT_UT().run()












class UT_UT extends UT
	run: ->
#		@t "UT events", (ut) ->
#			@eq ut.say_hi_to_peter, "Hi Pete!"
#			@testHub.startClient "/tmp/ut/UT_UT"
#			.then (client) =>
#				@log "one: #{client.one}"
#			.catch (ex) =>
#				@logCatch "startClient", ex		#H: logCatch WHAT should be the parameter?
		@t "opts", (ut) ->
			@log "ut.opts=", ut.opts
			@eq ut.opts.aaa, "AAA"
			@log "@opts=", @opts
			@eq @opts.aaa, "AAA"
		@t "empty log", ->
			@log "pre"
			if trace.HUMAN
				@log()
				@log()
				@log "post"
		@s "bag", ->
			@t "set", ->
				@bag()
				@bag.color = "red"
				@bag()
			@t "get", ->
				@bag()
				@eq @bag.color, "red"
				@bag.clear()
				@eq @bag.color, undefined
				@bag()
			@t "clear invalid", ->
				try
					@bag.clear = "this should fail"
					@fail "it's illegal to assign 'clear' to bag"
				catch ex
					@pass()
		@s "sync nesting test", ->
#			@log "SYNC"
#			t = 0
#			@log "div 0"
#			t = t / t
#			O.LOG this
#			@log "hello"
			@s "a", (ut) =>
#				@log "section log"
#				@logError "section logError"
#				@logCatch "section logCatch"

				@s "b1", (ut) ->
					@t "b1c1", (ut) ->
#						@log "test log"
#						@logError "test logError"
#						@logCatch "test logCatch"
					@t "b1c2", (ut) ->
				@s "b2", (ut) ->
					@s "b2c1", (ut) ->
						@t "b2c1d1", (ut) ->
		@s "async nesting test", (ut) ->
			@s "a", (ut) ->
				@s "b1", (ut) ->
					@a "b1c1", (ut) ->
						setTimeout (=> ut.resolve()), 10
					#						@log "setTimeout"
					#						@log "asynch log"
					#						@logError "asynch logError"
					#						@logCatch "asynch logCatch"
					@a "b1c2", (ut) ->
						ut.resolve()
				@s "b2", (ut) ->
					@s "b2c1", (ut) ->
						@a "b2c1d1", (ut) ->
							ut.resolve()
		@s "options", ->
			@s "general", ->
				@t "commented out", _desc:"this is not used", ->
			@s "specific", ->
				@T "exceptionMessage", exceptionMessage:"Deanna is beautiful", ->
					throw new Error "Deanna is beautiful"
				@s "expect", ->
					@t "assert", {expect:"ERROR"}, ->
						@log "hello"

						@assert true, "Saturday"
						@assert false, "Sunday"
					@_t "bManual: fatal", {comment:"can't test because it exits node",bManual:true}, ->
#						TODO: skip if bManual is true
						@fatal()
						@fatal "display me on console"
					@a "promise timeout", {timeout:10, expect:"TIMEOUT"}, (ut) ->
#						DO NOT CALL ut.resolve()
				@a "onTimeout", {
						timeout:10
						onTimeout: (ut) ->
							@log "onTimeout called: #{ut.opts.timeout}=#{@opts.timeout}"
							true
					}, (ut) ->
						@log "do not call ut.resolve to force timeout"
				@a "timeout", {timeout:1000}, (ut) ->
#							@log "opts parameter"
#							O.LOG ut.opts
					@eq ut.opts.timeout, 1000
					ut.resolve()
				@_t "seek exception but don't get one", {expect:"EXCEPTION", bManual:true}, ->
					@log "hello"
		@s "eq", ->
			#UT: two pass
			#UT: two fail
			#UT: third parameter description supported
			@t "single parameter", {
				onException: (ut, ex) ->
#					@log "in onException"
					@pass()
			}, ->
				@eq "I feel alone"

			@t "differing types", {desc:"@eq is NOT strict, i.e, it checks VALUE only (string vs. String is okay and passes"}, ->
#				@log "in test: *** bRunToCompletion=#{@bRunToCompletion}"
				@eq "peter", new String "peter"
			@s "HELP WHY CAPITALIZED? Eq", ->			#H: why repeat
				@t "single parameter", {
					onException: (ut, ex) ->
	#					@log "in onException"
						@pass()
				}, ->
					@Eq "I feel alone"

				@t "differing types", {expect:"EXCEPTION", desc:"@Eq is strict!, i.e., VALUE and TYPE must agree!"}, ->
	#				@log "in test: *** bRunToCompletion=#{@bRunToCompletion}"
					@Eq "peter", new String "peter"
		@a "@delay", (ut) ->
			@log "before"
			@delay 50
			.then (to) =>
				@log "timed out", to
				ut.resolve to
			.catch (ex) =>
				@logCatch "CATCH", ex
			@log "after"
		@t "one", (ut) ->
			@log()
			@log "one: #{@test.one}"
			@eq @test.one, "UT_UT/one"
		@s "misc", ->
#			@A "don't close", (ut) ->
#				@log "something doesn't stop"
#endif