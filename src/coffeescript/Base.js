// coffeeScript.coffee: Generated by CoffeeScript 2.3.1 (coffeescript.coffee IMMED5 affects ./coffee -v)
(function() {
  // process: ENV={"node":true,"rn":false,"ut":true,"source":"/Users/pete/gitlab/rn/API/Flexbase/Base.coffee"}
  var Base, CAP, EXPORTED, O, Util, V, m_openMap, m_stopMap, trace;

  /*
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
  */
  //import O
  O = require('./O');

  //import trace
  trace = require('./trace');

  //import Util
  Util = require('./Util');

  //import V
  V = require('./V');

  //DUP
  CAP = function(s) {
    if (s.length) {
      return s.charAt(0).toUpperCase() + s.slice(1);
    } else {
      return "";
    }
  };

  m_stopMap = {};

  m_openMap = new Map();

  EXPORTED = Base = class Base {
    //if ut
    static s_ut() {
      var BaseUT, UT;
      UT = require('./UT');
      return (new (BaseUT = class BaseUT extends UT {
        run() {
          this.t("log", function(ut) {
            if (trace.HUMAN) {
              this.log("standard log string");
              //						console.log "****************************************"
              return this.log({
                log: "some object"
              });
            }
          });
          //						@log "string", a:"object",pi:3.14159
          this.t("logg on/off", function(ut) {
            this.logg(false, "SHOW-NO");
            if (trace.HUMAN) {
              return this.logg(true, "SHOW-YES");
            }
          });
          this.t("logg object", function(ut) {
            if (trace.HUMAN) {
              return this.logg(true, "string", {
                a: "object",
                pi: 3.14159
              });
            }
          });
          return this._t("logX with omitted string", function() {
            if (trace.HUMAN) {
              this.logCatch({
                logCatch: "some object"
              });
              return this.logError({
                logError: "some object"
              });
            }
          });
        }

      })).run();
    }

    //endif
    constructor() {
      //DUP
      this.log = this.log.bind(this);
      this.logAssert = this.logAssert.bind(this);
      this.logCatch = this.logCatch.bind(this);
      //		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
      //		throw new Error "WHY?"			#WRONG: doesn't give correct stacktrace
      //		process.exit 1
      this.ex = this.ex.bind(this);
      this.CAT = this.CAT.bind(this);
      this.logError = this.logError.bind(this);
      //endif
      this.logFatal = this.logFatal.bind(this);
      //endif
      this.logInfo = this.logInfo.bind(this);
      this.logSilent = this.logSilent.bind(this);
      this.logTransient = this.logTransient.bind(this);
      this.logWarning = this.logWarning.bind(this);
      this.logg = this.logg.bind(this);
      //		@log "Base: #{@constructor.name}"

      //		@log "BASE CONSTRUCTOR", arguments		#T
      // 03:26 [undefined] BASE CONSTRUCTOR
      // 4:03:26 PM
      // >   found arguments (length=1)
      // 4:03:26 PM
      // >           ∟ arguments[0]: ws://localhost:4000
      this.__CLASS_NAME = this.constructor.name;
      //		@__CLASS_NAME2 = "222"
      this["@who"] = `class ${this.__CLASS_NAME}`;
    }

    //		for pn in ["","Assert","Catch","Error","Fatal","Info","Silent","Transient","Warning"]
    //#			console.log "*** #{pn}"
    //#			this[pn] = (s, v, opt) =>		Util.logBase @__CLASS_NAME, "#{pn}: #{s}", v, opt
    //#			this[pn] = do (pn) -> (s, v, opt) =>		Util.logBase @__CLASS_NAME, "#{pn}: #{s}", v, opt
    //			this["log#{CAP pn}"] = do (pn) => =>
    //				console.log "LEN=" + arguments.length
    //				O.LOG arguments
    //				a = Array.prototype.slice.call arguments
    //				O.LOG a
    //				switch a.length
    //					when 0
    //						console.log "when 0"
    //						Util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME]
    //					when 1
    //						console.log "when 1"
    //						Util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME, "#{pn.toUpperCase()}: #{a[0]}"]
    //					else
    //						console.log "when N"
    //						Util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME, "#{pn.toUpperCase()}: #{a[0]}", a[1]...]
    //				Util.abort()
    //#		O.LOG this

    //#		@logTransient()
    //		@logTransient "tr"
    //		@logTransient "tr", {a:"b"}
    //		@logTransient "tr", {a:"b"}, "c"
    //		Util.abort()
    AT_BASE() {}

    abort(msg) {
      return Util.abort(msg);
    }

    assert(b, msg) {
      if (!b) {
        throw Error(`ASSERTION FAILURE${(msg ? `: ${msg}` : "")}`, this.__CLASS_NAME);
      }
    }

    log() {
      var ref;
      return Util.logBase.apply(this, [(ref = this.__CLASS_NAME2) != null ? ref : this.__CLASS_NAME, ...arguments]);
    }

    logAssert(s, o, opt) {
      return Util.logBase(this.__CLASS_NAME, `ASSERT: ${s}`, o, opt);
    }

    logCatch(s, o, opt) {
      //		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
      return Util.logBase(this.__CLASS_NAME, `CATCH: ${s}`, o, opt);
    }

    ex(ex) {
      //		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
      Util.logBase(this.__CLASS_NAME, "ex:", ex);
      //		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
      return process.exit(1);
    }

    CAT(ex) {
      //		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
      Util.logBase(this.__CLASS_NAME, "Base.CAT:", ex);
      //		console.log "^^^^^^^^^^^^^^^^^^^^^^^^"
      return process.exit(1);
    }

    logError(s, o, opt) {
      Util.logBase(this.__CLASS_NAME, `ERROR: ${s}`, o, opt);
      //if node
      return process.exit(1);
    }

    logFatal(s, o, opt) {
      Util.logBase(this.__CLASS_NAME, `FATAL: ${s}:`, o, opt);
      //if node
      return process.exit(1);
    }

    logInfo(s, o, opt) {
      return Util.logBase(this.__CLASS_NAME, `INFO: ${s}`, o, opt);
    }

    logSilent(s, o, opt) {
      return Util.logBase(this.__CLASS_NAME, `SILENT: ${s}`, o, {
        bVisible: false //H: needs to merge options	#R: SILENT
      });
    }

    logTransient(s, o, opt) {
      return Util.logBase(this.__CLASS_NAME, `TRANSIENT: ${s}`, o, opt);
    }

    logWarning(s, o, opt) {
      if (trace.WARNINGS) {
        return Util.logBase(this.__CLASS_NAME, `WARNING: ${s}`, o, opt);
      }
    }

    //			Util.logBase.apply this, [@__CLASS_NAME2 ? @__CLASS_NAME, "WARNING", arguments...]

    //H: since this then just try this!
    static _log(s) {
      return Util.logBase("Base(static)", s);
    }

    static logOpenMap() {
      var doNotRemoveThis, dump, now;
      if (m_openMap.size) {
        this._log(`^|||	m_openMap.size=${m_openMap.size}`);
        now = Date.now();
        dump = (k, rec) => {
          return this._log(`^|||	"${rec.moniker}" open for ${now - rec.msOpen}ms`);
        };
        m_openMap.forEach((v, k) => {
          return dump(k, v);
        });
        return doNotRemoveThis = true;
      } else {
        return this._log("^|||	logOpenMap: nothing left open");
      }
    }

    static auditEnsureClosed() {
      //		console.log "^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{m_openMap.size}"
      if (m_openMap.size) {
        Base.logOpenMap();
        throw new Error("auditEnsureClosed: NOT ALL CLOSED!!!");
      }
    }

    auditOpen(moniker) {
      if (arguments.length !== 1) {
        throw new Error("only pass one argument");
      }
      if (m_openMap.get(this)) {
        Base.logOpenMap();
        this.throw(`auditOpen: ${moniker}: already open`);
      }
      m_openMap.set(this, {
        moniker: moniker,
        msOpen: Date.now()
      });
      return this.logg(trace.AUDIT, `auditOpen ${moniker}: count=${m_openMap.size}`);
    }

    auditClose(moniker) {
      var rec;
      if (!(rec = m_openMap.get(this))) {
        Base.logOpenMap();
        this.throw(new Error("auditClose #1: NOT IN m_openMap!!!"));
      }
      if (moniker !== rec.moniker) {
        throw new Error(`monikers don't match: ${rec.moniker} vs ${moniker}`);
      }
      if (m_openMap.delete(this)) {
        return this.logg(trace.AUDIT, `auditClose ${moniker}: count=${m_openMap.size}`);
      } else {
        return this.throw(`auditClose ${moniker} #2: NOT IN m_openMap!!!`);
      }
    }

    E(code) {
      throw new Error(501); // not implemented
    }

    logg(b, s, o, opt) {
      var a, ref;
      if (!!b) {
        //			console.log "enabled"
        a = Array.prototype.slice.call(arguments);
        if (this.mn) {
          a[1] = `{${this.mn}} ${a[1]}`;
        }
        //			O.LOG a
        a.splice(0, 1);
        return Util.logBase.apply(this, [(ref = this.__CLASS_NAME2) != null ? ref : this.__CLASS_NAME, ...a]);
      }
    }

    //		else
    //			console.log "disabled"
    m(mn) {
      this.mn = mn;
    }

    //		@log "m: #{@mn}"
    static openCntGet() {
      return m_openMap.size;
    }

    static openMsgGet() {
      var _, s;
      s = "All resources closed.  ";
      if (_ = m_openMap.size) {
        s = `${_} resource${(_ === 1 ? "" : "es")} left open!!!   `;
      }
      return s;
    }

    prop(prop, desc) {
      return Object.defineProperty(this, prop, desc);
    }

    //if 1
    //DEBUG
    stop(key, cnt) {
      if (m_stopMap[key] == null) {
        m_stopMap[key] = 0;
      }
      if (++m_stopMap[key] === cnt) {
        throw new Error(`STOP "${key}" cnt=${cnt}`);
      }
    }

    //endif
    tassert(v, type) {
      //		@log type
      return this.assert(V.type(v) === type, `tassert: expecting=${type} got=${V.type(v)}`);
    }

    throw(v) {
      throw new Error(v);
    }

  };

  module.exports = EXPORTED;

}).call(this);
