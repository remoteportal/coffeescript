###
Date - Date functions					*** PROJECT AGNOSTIC ***


WHAT: Node module


DESCRIPTION



FEATURES
-


NOTES
-


TODOs
- UT		#H


KNOWN BUGS:
-
###





#if node
fs = require 'fs'
NODE_util = require 'util'
#elseif rn
#import Expo, { FileSystem } from 'expo'
#endif

N = require './N'
O = require './O'
trace = require './trace'





dateTimeHyphenated = ->
	today = new Date
	dd = today.getDate()
	mm = today.getMonth() + 1
	yyyy = today.getFullYear()
	if dd < 10
		dd = '0' + dd
	if mm < 10
		mm = '0' + mm
	"#{yyyy}-#{mm}-#{dd} #{N.ZEROPAD today.getHours(), 2}-#{N.ZEROPAD today.getMinutes(), 2}-#{N.ZEROPAD today.getSeconds(), 2}"


MMSS = -> "#{N.ZEROPAD (date=new Date).getMinutes(), 2}:#{N.ZEROPAD date.getSeconds(), 2}"




module.exports =
	dateTimeHyphenated: dateTimeHyphenated
	MMSS: MMSS
#if ut
	s_ut: ->
		UT = require './UT'

		(new (class Date_UT extends UT
			run: ->
				@t "MMSS", (ut) ->
					@log "MMSS: #{MMSS()}"
		)).run()
#endif