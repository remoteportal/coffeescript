// coffeescript.js: Generated by CoffeeScript GITLAB/lib 2.3.0
/*
V - Value functions					*** PROJECT AGNOSTIC ***

WHAT: Node module

DESCRIPTION

FEATURES
-

NOTES
- "A primitive (primitive value, primitive data type) is data that is not an object and has no methods. In JavaScript, there are 6 primitive data types: string, number, boolean, null, undefined, symbol"

TODOs
- throw error if find new datatype

KNOWN BUGS:
-
*/
var COMPARE_REPORT, DUMP, EQ, KV, LOG_DELTA, LOG_MULTI, LOG_SINGLE, NOT_STRING, PAIR, RE_ISOLATE_TYPE, SINGLE, Type, trace, type;

trace = require('./trace');

// [object Function]
RE_ISOLATE_TYPE = /\[object ([^\]]*)\]/;

COMPARE_REPORT = function(v0, v1) { //H: string-oriented or value (V)-oriented?
  var S, bStrings, buf, j, len, ref, v;
  buf = '';
  if (s0 === s1) {
    buf = "values are the same";
  } else {
    bStrings = true;
    ref = [v0, v1];
    for (j = 0, len = ref.length; j < len; j++) {
      v = ref[j];
      if (!IS(v)) {
        bStrings = false;
      }
    }
    if (bStrings) {
      S = require('./S');
      buf = S.COMPARE_REPORT(v0, v1);
    } else {
      //TODO: see if integer and float.... negative/positive: EXPLAIN difference between the values
      buf = "values are different"; //HACK
    }
  }
  return buf;
};

// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects
DUMP = function(v) {
  var O, Ty, ex;
  try {
    //		type = Object::toString.call v
    //		# [object Function]
    //		re = /\[object ([^\]]*)\]/
    //		match = re.exec type
    //		if match
    //			console.log "match=#{match[1]}"
    //		else
    //			console.error "DUMP: unable to isolate type from: \"#{type}\""
    //			process.exit 1
    if (v != null) {
      Ty = Type(v);
      //			console.log "V.DUMP: DEBUG: {v} ARRAY=#{Array.isArray v} TYPEOF=#{typeof v} TYPE=#{Ty} JSON=#{JSON.stringify v}"
      switch (Ty) {
        case "Boolean":
        case "boolean":
        case "Number":
        case "number":
          return v;
        case "function":
          return "FN";
        //					v
        case "Promise":
          //TODO: dump attributes
          return `${v} <Promise>`;
        case "Response":
          O = require('./O');
          //					O.LOG v		#INFINITE_LOOP
          //HACK
          //					for k,v of v
          //						O.LOG v
          return `RESPONSE: ${JSON.stringify(v)}`;
        case "String":
        case "string":
          if (v.length === 0) {
            return "\"\"";
          } else {
            return v;
          }
          break;
        case "Uint8Array":
          //					"#{v} <#{Ty}> #{JSON.stringify v}"
          return `Uint8Array: len=${v.length}: buffer=${v}: JSON=${JSON.stringify(v)}`;
        default:
          return `${v} <${Ty}> UNKNOWN`;
      }
    } else {
      //			console.log "V.DUMP: DEBUG: {v} ARRAY=#{Array.isArray v} TYPEOF=#{typeof v} TYPE=#{Ty} JSON=#{JSON.stringify v}"
      //			"null or undefined"
      return "null"; //H #WARNING
    }
  } catch (error) {
    ex = error;
    console.error(`V.DUMP exception: ${ex}`);
    return process.exit(1);
  }
};

EQ = function(a, opts = {}) {
  var _, bEQ, i, j, l, ref, ref1, s;
  bEQ = true;
  //	@logSilent "inside eq: a.length=#{a.length}"

  //		@log "ut: bRunToCompletion=#{@bRunToCompletion}"
  if (a.length >= 2) {
    if (!(a[0] != null) && !(a[1] != null)) {

    } else {
      //			@logSilent "both undefined"
      if (opts.bTypes) {
        //				console.log "---CHECK TYPES---"
        _ = type(a[0]);
//			process.exit 1
        for (i = j = 0, ref = a.length - 1; (0 <= ref ? j <= ref : j >= ref); i = 0 <= ref ? ++j : --j) {
          //				@log "arg#{i}: #{PAIR a[i]} #{typeof a[i]}"
          //				@log "arg#{i}: #{PAIR a[i]} #{typeof a[i]} --> #{S.DUMP type(a[i]), true}"
          //				@log "#{_}-#{type a[i]}"
          if (_ !== type(a[i])) {
            bEQ = false;
          }
        }
        //					console.log "TTTTTTTTTT"
        //			console.log "aaa"
        if (!bEQ) {
          s = "@eq types violation:\n";
          for (i = l = 0, ref1 = a.length - 1; (0 <= ref1 ? l <= ref1 : l >= ref1); i = 0 <= ref1 ? ++l : --l) {
            s += `> arg${i}: ${type(a[i])}\n`;
          }
          //				@log "ut2: bRunToCompletion=#{@bRunToCompletion}"
          //					@logError s
          console.log(s);
        }
      }
      if (bEQ) {
        //				console.log "---CHECK VALUES---"
        bEQ = true;
        //				_ = a[0]
        //				for i in [0..a.length-1]
        //					console.log "arg#{i}: #{PAIR a[i]} #{typeof a[i]}"

        //					#WARNING: old code used to sometime hang node; it was very bizarre
        //					#NOTE #REVELATION: "peter" NOT-EQUAL-TO new String "peter" so force to string first!!!!!!!!!!!!!
        //					unless ""+_ is ""+a[i]
        //						bEQ = false
        // console.log "i=#{i}: #{_}-#{a[i]}"
        if ("" + a[0] !== "" + a[1]) {
          bEQ = false;
        }
        if (!bEQ) {
          LOG_DELTA(a[0], a[1]);
        }
      }
    }
  }
  return bEQ;
};

KV = function(k, v, bReverse) {
  var O;
  O = require('./O');
  if (bReverse) {
    return `${k} = <${Type(v)}> ${O.duck(v)}`;
  } else {
    return `${k} = ${O.duck(v)} <${Type(v)
//TODO: distinquish between primative and non-primative
}>`;
  }
};

LOG_DELTA = function(v1, v2) {
  var O, S, a, s, t1, t2;
  O = require('./O');
  S = require('./S');
  t1 = typeof v1;
  t2 = typeof v2;
  a = [
    v1,
    v2 //HACK
  ];
  if ((t1 === t2 && t2 === "string")) {
    s = "@eq values violation:\n";
    s += `> arg${a[0]}: ${PAIR(a[0])} DUMP: ${S.DUMP(a[0], void 0, true)}\n`;
    s += `> arg${a[1]}: ${PAIR(a[1])} DUMP: ${S.DUMP(a[1], void 0, true)}\n`;
    //					@logError s
    return console.log(s);
  } else {
    console.log("LOG_DELTA: not strings");
    O.LOG(v1);
    return O.LOG(v2);
  }
};

//NOTE: tabs look wrong but are actually right
LOG_MULTI = function(v, pn) {
  var ex;
  console.log("\n\n\n\n\n\n\n\n\n\n");
  console.log("O.LOG:");
  console.log(`JSON:			${JSON.stringify(v)}`);
  console.log(`JSON len:		${(JSON.stringify(v).length)}`);
  console.log(`isArray:		${Array.isArray(v)}`);
  console.log(`typeOf:			${typeof v}`);
  console.log(`type:			${Object.prototype.toString.call(v)}`);
  if (v instanceof Uint8Array) {
    return console.log("Uint8Array");
  } else {
    try {
      //			console.log "as string:		#{""+v}"		# argument should be a Buffer
      console.log(`as string:		${v.toString()}`);
      console.log(`as string len:		${("" + v).length}`);
      console.log("===============================================");
      try {

      } catch (error) {}
      return `${(pn ? `${pn}=` : "")}${v} ARRAY=${Array.isArray(v)} TYPEOF=${typeof v} TYPE=${Object.prototype.toString.call(v)} JSON=${JSON.stringify(v)}`;
    } catch (error) {
      ex = error;
      console.log("LOG_MULTI EXCEPTION: *****************************");
      return console.log(ex);
    }
  }
};

//			process.exit 1
LOG_SINGLE = function(v, pn) {
  return console.log(SINGLE(v, pn));
};

NOT_STRING = function(v) {
  if (type(v) === "string") {
    //		console.log "ooo=#{type v}"
    if (v.length) {
      return v;
    } else {
      return "\"\"";
    }
  } else {
    return PAIR(v);
  }
};

PAIR = function(v) {
  return `${v} <${Type(v)
//TODO: distinquish between primative and non-primative
}>`;
};


// "peter"				=>
// new String "peter"	=>
//typeMap = {}
//TYPE = (v) ->
//#	if _=typeMap[v]
//#		_
//#	else

//	type = Object::toString.call v

//	match = RE_ISOLATE_TYPE.exec type
//	if match and match.length >= 2
//#		console.log "match=#{match[1]}"

//# primative vs. non-primative types
//		if typeof v is "object"
//			type = match[1]
//		else
//			type = typeof v

//		console.log "#{v} => #{type}"
//#			typeMap[v] = type
//	else
//		util.abort "V.TYPE: Unable to isolate type substring from: \"#{type}\""
//TYPE = (v) ->		#DEP
//#	console.log "TYPE: v=#{v}"
//#	console.log "TYPE: typeof v=#{typeof v}"
//#	console.log "TYPE: call v=#{Object::toString.call v}"

//	# primative vs. non-primative types
//	if typeof v is "object"
//		type = Object::toString.call v

//		match = RE_ISOLATE_TYPE.exec type
//		if match and match.length >= 2
//#			console.log "match=#{match[1]}"
//			typeMap[v] = type = match[1]		#WRONG: need REAL ES6 Map
//			console.log "#{v} => #{type} (call)"
//		else
//			util.abort "V.TYPE: Unable to isolate type substring from: \"#{type}\""
//	else
//		type = typeof v
//		console.log "#{v} => #{type} (typeof)"

//	type
SINGLE = function(v, pn) {
  var ex;
  try {
    return `${(pn ? `${pn}=` : "")}${v} ARRAY=${Array.isArray(v)} TYPEOF=${typeof v} TYPE=${Object.prototype.toString.call(v)} JSON=${JSON.stringify(v)}`;
  } catch (error) {
    ex = error;
    console.log("SINGLE EXCEPTION: *****************************");
    console.log(ex);
    return LOG_MULTI(v);
  }
};

//		process.exit 1

// "peter"				=> string
// new String "peter"	=> String		Capitalized!
//THROWS
Type = function(v) {
  var match, t;
  // primative vs. non-primative types
  if (typeof v === "object") {
    t = Object.prototype.toString.call(v);
    match = RE_ISOLATE_TYPE.exec(t);
    if (match && match.length >= 2) {
      //			console.log "match=#{match[1]}"
      t = match[1];
    } else {
      //			console.log "#{v} => #{t} (call)"
      util.abort(`V.Type: Unable to isolate type substring from: "${t}"`);
    }
  } else {
    t = typeof v;
  }
  //		console.log "#{v} => #{t} (typeof)"
  return t;
};

// "peter"				=> string
// new String "peter"	=> string		lower-case!
type = function(v) {
  var match, t;
  // 	primative vs. non-primative types
  if (typeof v === "object") {
    t = Object.prototype.toString.call(v);
    match = RE_ISOLATE_TYPE.exec(t);
    if (match && match.length >= 2) {
      //			console.log "match=#{match[1]}"
      t = match[1].toLowerCase();
    } else {
      //			console.log "#{v} => #{t} (call)"
      util.abort(`V.type: Unable to isolate type substring from: "${t}"`);
    }
  } else {
    t = typeof v;
  }
  //		console.log "#{v} => #{t} (typeof)"
  return t;
};

module.exports = {
  COMPARE_REPORT: COMPARE_REPORT,
  DUMP: DUMP,
  //	EQ: (v1, v2) -> console.log "COMP: #{v1} vs. #{v2} (#{typeof v1}) vs (#{typeof v2}) #{if v1 is v2 then "YES-MATCH" else "NO-MATCH"}"	#USED?
  EQ: EQ,
  KV: KV,
  LOG_DELTA: LOG_DELTA,
  LOG_MULTI: LOG_MULTI,
  LOG_SINGLE: LOG_SINGLE,
  NOT_STRING: NOT_STRING,
  PAIR: PAIR,
  SINGLE: SINGLE,
  TYPE: Type, //DEP
  Type: Type,
  type: type,
  //if ut
  s_ut: function() {
    var UT, VU_UT;
    UT = require('./UT');
    VU_UT = class VU_UT extends UT {
      run() {
        this.t("DUMP", function() {
          if (trace.UT_TEST_LOG_ENABLED) {
            this.log(DUMP("literal string"));
            this.log(DUMP(new String("string object")));
            this.log(DUMP({
              a: "a"
            }));
            this.log(DUMP(45));
            this.log(DUMP(true));
            this.log(DUMP(void 0));
            this.log(DUMP(null));
            //						@log DUMP VUT
            this.log(DUMP(function() {}));
            this.log(DUMP([]));
            this.log(DUMP(new Date()));
            return this.log(DUMP(new Uint16Array()));
          }
        });
        this.t("EQ", function() {
          this.log("EQ");
          this.assert(EQ([1, 1]));
          //			@assert EQ [1, 2]
          return this.assert(EQ(["aaa", "aaa"]));
        });
        //			@assert EQ ["aaa", "bbb"]
        this.t("Type", function() {
          this.eq(Type(45), "number");
          this.eq(Type(new Number(45)), "Number");
          this.eq(Type(new Number(45)), "Number");
          this.eq(Type("literal string"), "string");
          this.eq(Type(new String("string class")), "String");
          this.eq(Type(null), "Null");
          this.eq(Type(void 0), "undefined");
          this.eq(Type(function() {}), "function");
          this.eq(Type(new Date()), "Date");
          this.eq(Type(new Uint32Array()), "Uint32Array");
          this.eq(Type([]), "Array");
          this.eq(Type(true), "boolean");
          return this.eq(Type(new Boolean(false)), "Boolean");
        });
        this.t("type", function() {
          this.eq(type(45), "number");
          this.eq(type(new Number(45)), "number");
          this.eq(type(new Number(45)), "number");
          this.eq(type("literal string"), "string");
          this.eq(type(new String("string class")), "string");
          this.eq(type(null), "null");
          this.eq(type(void 0), "undefined");
          this.eq(type(function() {}), "function");
          this.eq(type(new Date()), "date");
          this.eq(type(new Uint32Array()), "uint32array");
          this.eq(type([]), "array");
          this.eq(type(true), "boolean");
          return this.eq(type(new Boolean(false)), "boolean");
        });
        return this.t("Uint8Array NOT", function() {
          var uint8;
          //			json = '{"type":"Buffer","data":[123,34,99,34,58,34,99,32,118,97,108,117,101,34,125]}'
          //			o = JSON.parse json
          //			LOG_MULTI o
          //			LEARN: hoping would be type=Uint8Array but it's not
          if (trace.HUMAN) {
            uint8 = new Uint8Array(2);
            uint8[0] = 42;
            console.log(uint8[0]);
            // 42
            console.log(uint8.length);
            // 2
            console.log(uint8.BYTES_PER_ELEMENT);
            // 1
            LOG_MULTI(uint8);
            return this.log(`GGGGGGGGGGG=${DUMP(uint8)}`);
          }
        });
      }

    };
    return new VU_UT().run();
  }
};

//endif
