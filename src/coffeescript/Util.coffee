#if node
fs = require 'fs'
NODE_util = require 'util'
#elseif rn
#import Expo, { FileSystem } from 'expo'
#endif


N = require './N'
O = require './O'
#trace = require './trace'


m_logStream = null
m_logEmptyNextCharacter = 'A'


#TODO: log multiple objects before options

#H: try to move these into concrete S, N, O, etc., files???










#DUP
RE_ISOLATE_TYPE = /\[object ([^\]]*)\]/
#DUP
type = (v) ->
# 	primative vs. non-primative types
	if typeof v is "object"
		t = Object::toString.call v

		match = RE_ISOLATE_TYPE.exec t
		if match and match.length >= 2
#			console.log "match=#{match[1]}"
			t = match[1].toLowerCase()

#			console.log "#{v} => #{t} (call)"
		else
			util.abort "V.type: Unable to isolate type substring from: \"#{t}\""
	else
		t = typeof v
	#		console.log "#{v} => #{t} (typeof)"

	t







abort = (msg) ->
	m_logStream = null		#RECENT2

#if node
	console.error "#".repeat 60
	if msg
		console.error "NODE ABORTED#{if msg then ": #{msg}" else ""}"
	else
		console.error "ABORTING NOW!!! (log will be truncated...)"
	console.error "#".repeat 60
#	process.exit 1
	throw new Error "util.abort() called!"
#else
#		throw "ABOPT!!!!!!!!!!!!!!!!!!"
#endif



exitAfterSlightDelay__soThatLogCanFinishWriting = (ms = 500) ->
	console.error "***************************** exitAfterSlightDelay__soThatLogCanFinishWriting PRE"
	process.exit 1		# T


	setTimeout =>
		console.error "***************************** exitAfterSlightDelay__soThatLogCanFinishWriting POST"
		process.exit 1
	,
		ms



fileDownload = (URL, path) ->
	log = (s, v) -> logBase "fileDownload", s, v
	logCatch = (ex) -> logBase "fileDownload", "CATCH", ex

	new Promise (resolve, reject) =>
		try
#			log "#{URL} => #{path}"

			fs = require 'fs'
			request = require 'request'

			file = fs.createWriteStream path
			file.on 'finish', ->
#				log "finished"
				file.close =>
#					log "closed"
					resolve path
			file.on 'error', (err) ->
#				log "file on error", err
				fs.unlink path		#ASYNC: but don't wait
				reject err
#			log "file", file

			sendReq = request.get URL
			sendReq.on 'response', (response) ->
#				log "on response", response
#				log "response.statusCode=#{response.statusCode}"
				if response.statusCode != 200
					reject new Error "response: statusCode=#{response.statusCode}"
			sendReq.on 'error', (err) ->
				log "request on error", err
				fs.unlink path		#ASYNCH	#UNNECCESSARY: @util.promisify(fs.unlink) path
				reject err
			sendReq.pipe file
#			log "sendReq", sendReq
		catch ex
			console.log "catch"
			logCatch ex
			reject ex



fs_directoryEnsure = (directory, cb) ->
#		console.log "fs_directoryEnsure: #{directory}"

		fs.access directory, fs.constants.W_OK, (err) =>
			if err
				if err.code is "ENOENT"
#					@log "mkdir: #{directory}"
					fs.mkdir directory, (err) =>
						if err
#							@logError "mkdir", err
							cb err
						else
							cb()
				else
#					@logError "access", err
					O.LOG err
					cb err
			else
#				@log "already exists"
				cb()



fs_directoryDeleteRecursive = (directory) ->
#	console.log "fs_directoryDeleteRecursive: #{directory}"

	if fs.existsSync directory
		fs.readdirSync(directory).forEach (file, index) ->
			curPath = directory + '/' + file
			if fs.lstatSync(curPath).isDirectory()
				fs_directoryDeleteRecursive curPath
			else
#				console.log "fs_directoryDeleteRecursive: unlink: #{curPath}"
				fs.unlinkSync curPath
		fs.rmdirSync directory



# usage:
# fnn, s, v, bDeep
# fnn, s, v0, v1, ..., vN		where any v can be opts object
logBase = (fnn, s, v, optionsObjectOrO_LOG_flag) ->		#H #MESS
#	console.log "logBase"
#	O.LOG arguments
#	abort()

	opts =
		bVisible: true
		bDeep: true

#	a = arguments.slice()
	# copy array

	a = Array.prototype.slice.call arguments, 1
#HELPFUL #DEBUGGING
#	O.LOG a
#	abort()


	if type(a[0]) isnt "string"
#		console.log "1111111111 #{type a[0]} (#{type(a[0]) isnt "string"}) 1111111111 #{JSON.stringify a}"
		a.unshift ""
#		console.log "2222222222 #{JSON.stringify a}"
		optionsObjectOrO_LOG_flag = v
		v = s
		s = ""


	# ARGUMENTS SHIFT LEFT!
	# now:
	#	0	1	2
	#	s, v, opt
#	O.LOG a

	if a.length is 3 and typeof optionsObjectOrO_LOG_flag is "boolean"
		opts.bDeep = optionsObjectOrO_LOG_flag
#		console.log "boolean passed as third argument: bDeep=#{opts.bDeep}"
		a.splice 2, 1
#		O.LOG a
#		console.log "len=#{a.length}"
#	abort()

	if a.length > 2
#		console.log "look for options object"
#		O.LOG a
		for i in [0, a.length - 1]
#			O.LOG a[i]
			if typeof a[i] is "object"
				bFoundOpts = false
				for opt in ["bDeep", "bVisible"]
					if opt of a[i]
						# override specific opts
						for pn, pv of a[i]
#							console.log "opt: override: #{pn}=#{a[i][pn]}"
							opts[pn] = a[i][pn]
#	console.log "FUCKING MESS"


	vPart = ""
	extra = ""
	try
		if v?
#			console.log "v?"
#			O.LOG v
#			if v instanceof String
#				extra = ""
			if v instanceof Error
				unless opts.bDeep
					extra = ": #{v.stack}"
			else if typeof v is "object"
				unless opts.bDeep
					extra=" #{JSON.stringify v}"
			else
				V = require './V'
				extra = " " + V.NOT_STRING v
		else if a.length > 1
#			console.log "**************************"
			extra = " NULL"	#: a.length=#{a.length}"		#HELP #NEEDS-LOVE
#			O.LOG a
	catch ex
		extra = ": LOG_BASE INTERNAL EXCEPTION: #{ex}"

	# log() draws a "horizontal rule" line of chars if no string passed
#	console.log "s=#{s}"
#	O.LOG arguments
	if !s and arguments.length is 1
#		console.log "****fff****"
#		O.LOG arguments
#		throw new Error "FATAL"
		a.push extra = m_logEmptyNextCharacter.repeat 60
		m_logEmptyNextCharacter = String.fromCharCode(m_logEmptyNextCharacter.charCodeAt(0) + 1)
		s = ""

	if s?.length > 1 and s[0] is '^'
		# omit header for strings that start with ^
		line = "#{s[1..]}#{extra}"
	else
		line = "#{MMSS()} [#{fnn}] #{s}#{extra}"

#	console.log "VVVVVVVVVVVVVVV deep=#{opts.bVisible} v=#{v}"

	if opts.bVisible
		console.log line

#		console.log "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

		if opts.bDeep and v
#			console.log "***************** v=#{v}"
#			console.log "*****************"
			O.LOG v
#		O.LOG a...
	
	if line.indexOf("[_Client] object") > 0
		abort "&&&&&&&&&&&&&&&&&&&&&&&&&&&"
#		console.log "HELP: #{line}"

	if m_logStream?
		m_logStream.write "#{line}\n"



latestGet = (clo, fq) ->
	version = 0
	while clo["version#{version+1}"]
		version++
#	logBase "util", "version=#{version}"
	if latest = clo["version#{version}"]
		latest
	else
		logBase "util", "[#{fq}] Can't find version", clo, true
		null



MMSS = -> "#{N.ZEROPAD (date=new Date).getMinutes(), 2}:#{N.ZEROPAD date.getSeconds(), 2}"


pickRnd = (nameSpace, csl) ->
	a = csl.split ","
	a[rnd 0, a.length - 1]


#DUP?	N
rnd = (min, max) -> Math.floor(Math.random()*(max-min+1)+min)


#uploadAudioAsync = (uri) ->
#	new Promise (resolve, reject) =>
#		@log "uploadAudioAsync: uri=#{uri}"
#
#		# let apiUrl = 'https://file-upload-example-backend-dkhqoilqqn.now.sh/upload'
#		apiURL = 'http://www.skillsplanet.com:3399/upload'
#
#		uriParts = uri.split '.'
#		fileType = uriParts[uriParts.length - 1]
#
#		GUID = fb.GUID();
#
#		@log "uploadAudioAsync: #{GUID}.#{fileType}"
#
#		formData = new FormData()
#		formData.append 'avatar', uri,
#			name: "#{GUID}.#{fileType}",
#			type: "image/#{fileType}"
#
#		options =
#			method: 'POST'
#			body: formData
#			headers:
#				Accept: 'application/json'
#				'Content-Type': 'multipart/form-data'
#
#		fetch(apiURL, options).then (json) =>
#			@log "fetch success", json
#			if json._bodyText
#				O = JSON.parse json._bodyText
#				@log "key=#{O.key}"
#				#					if O.key is "key here"
#				#						resolve "#{GUID}.#{fileType}"
#				#					else
#				#						reject O
#				resolve "#{GUID}.#{fileType}"
#			else
#				reject "json._bodyText is empty"
#		.catch (ex) =>
#			@logCatch "fetch", ex
#			reject ex



size_pr = (path) -> #CONVENTION
#	@util.promisify fs.stat		won't work because need to return size
	new Promise (resolve, reject) =>
		fs = require 'fs'

		fs.stat path, (err, stats) =>
#			@log "err", err
#			@log "stats", stats
			if err
				reject err
			else
				resolve stats.size








module.exports =
#if ut
	s_ut: ->
		UT = require './UT'

		(new (class UtilUT extends UT
			run: ->
				@t "rnd", ->
					b = true

					for i in [0..99]
#						@log "rnd=#{rnd 10, 12}"
						b &= 10 <= rnd(10,12) <= 12

					@assert b
				@a "size_pr", (ut) ->
					size_pr ut.filepath 'deanna.png'
					.then (size) =>
						@eq size, 26042
						ut.resolve()
					.catch (ex) =>
						ut.reject ex
		)).run()
#endif




	abort: abort
	exit: (msg) ->
		m_logStream?.end "\n--EOF but PREMATURE EXIT: #{msg}--"
		m_logStream = null

#if node
		console.error "#".repeat 60
		if msg
			console.error msg
		else
			console.error "told to exit"
		console.error "#".repeat 60
		console.error "Exiting node..."
		exitAfterSlightDelay__soThatLogCanFinishWriting()
#else
#		console.error "#".repeat 60
#		if msg
#			console.error msg
#		else
#			console.error "EXIT NOT POSSIBLE"
#		console.error "#".repeat 60
#endif
	fileDownload: fileDownload
	fs_directoryEnsure: fs_directoryEnsure
	fs_directoryEnsurePromise: (directory) -> NODE_util.promisify(fs_directoryEnsure) directory
	fs_directoryDeleteRecursive: fs_directoryDeleteRecursive
	latestGet: latestGet
	logBase: logBase
	pickRnd: pickRnd
	rnd: rnd
	size_pr: size_pr
	streamSet: (_) -> m_logStream = _
#	uploadAudioAsync: uploadAudioAsync