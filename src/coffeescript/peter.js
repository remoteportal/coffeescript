// coffeescript.js: Generated by CoffeeScript GITLAB/lib 2.3.0
var O, OUTPUT, PROC, lg, log, process, trace;

OUTPUT = 1;

O = require('./O');

trace = require('./trace');

log = function(line) {
  return process.stdout.write(line + '\n');
};

log = function(line) {
  return console.log(line + '\n');
};

lg = function(line) {
  return console.log(line);
};

process = function(code, ENV = {}) {
  var a, arg, doReq, j, k, len, len1, line, lineNbr, lines, name, out, req, stack, th;
  if (OUTPUT) {
    lg(`ENV=${JSON.stringify(ENV)}`);
  }
  code = code.toString();
  //	log "FILE: SRC1: #{code}\n"
  a = [];
  if (OUTPUT) {
    a.push(`# process: ENV=${JSON.stringify(ENV)}`);
  }
  //		a.push "# cooked: "+new Date()		#GIT-NOISE
  stack = [];
  arg = function(line) {
    var tokens;
    tokens = line.split(' ');
    //		log "arg: #{tokens[1]}"
    return tokens[1].trim();
  };
  req = {
    bAlive: true,
    bChainAlive: true,
    bFoundIF: false,
    bFoundELSE: false
  };
  lines = code.split('\n');
//TODO #EASY: add ifdef end
//TODO: add switch, elseif?
//TODO: residue comment: //if node
  for (lineNbr = j = 0, len = lines.length; j < len; lineNbr = ++j) {
    line = lines[lineNbr];
    //		line = line.replace /?harles/, 'Christmas'

    //		lg "------------------------------------ LINE #{lineNbr+1}: #{line}"

    //SLOW: set for EACH LINE!
    th = function(msg) {
      var env, i, k, ref, ref1, start;
      env = Object.keys(ENV).sort().join(',');
      start = Math.max(0, lineNbr - 20);
      lg(`----------------------- ${msg}`);
      for (i = k = ref = start, ref1 = lineNbr; (ref <= ref1 ? k <= ref1 : k >= ref1); i = ref <= ref1 ? ++k : --k) {
        lg(`CONTEXT: LINE ${i + 1}: ${lines[i]}`);
      }
      if (OUTPUT) {
        throw Error(`line=${lineNbr + 1}: depth=${stack.length} ENV=${env} stack=${JSON.stringify(stack)}${(req.name ? ` name=${req.name}` : "")}: ${msg}`);
      } else {
        throw Error(`line=${lineNbr + 1}: depth=${stack.length}${(req.name ? ` name=${req.name}` : "")}: ${msg}`);
      }
      return process.exit(1);
    };
    doReq = function(name, bFlipIII) {
      var ref;
      req.name = name;
      req.bFoundIF = true;
      //			"client" needs to be turned on for node for unit testing
      if ((ref = req.name) !== "0" && ref !== "1" && ref !== "aws" && ref !== "client" && ref !== "daemon" && ref !== "dev" && ref !== "fuse" && ref !== "instrumentation" && ref !== "mac" && ref !== "node" && ref !== "node8" && ref !== "rn" && ref !== "ut" && ref !== "web" && ref !== "win") {
        th("unknown env target");
      }
      // only go if this target is one of the environments
      req.bAlive = (function() {
        switch (req.name) {
          case "0":
            return false;
          case "1":
            return true;
          default:
            return !!ENV[req.name];
        }
      })();
      if (req.bAlive) {
        return req.bChainAlive = false; // no FURTHER action (after this #{else}if) of this chain
      }
    };
    switch (false) {
      // log ">>> doReq: name=#{req.name} bChainAlive=#{req.bChainAlive} bAlive=#{req.bAlive}"
      case line.slice(0, 3) !== "#if":
        if (OUTPUT) {
          // log ">>> if: bChainAlive=#{req.bChainAlive} bAlive=#{req.bAlive}"
          a.push(line);
        }
        name = arg(line);
        // save current requirements for later
        stack.push(req);
        //CHALLENGE: why clone?  appears to break if just set req={}   !!!
        // clone (otherwise side offect of messing with requirements object just saved)
        req = Object.assign({}, req);
        if (req.bAlive) {
          //					log "bAlive SETS bChainAlive"
          req.bChainAlive = true;
          doReq(name, true);
        } else {
          req.bChainAlive = false;
        }
        req.bFoundELSE = false;
        break;
      case line.slice(0, 7) !== "#elseif":
        if (OUTPUT) {
          a.push(line);
        }
        if (req.bFoundELSE) {
          th("#elseif following #else");
        }
        //				lg "elseif: bChainAlive=#{req.bChainAlive}"
        req.bAlive = false;
        if (req.bChainAlive) {
          name = arg(line);
          // replace requirements with new name, keep same requirement object
          doReq(name);
        }
        break;
      case line.slice(0, 5) !== "#else":
        if (OUTPUT) {
          a.push(line);
        }
        if (!req.bFoundIF) {
          th("#else without #if");
        }
        if (req.bFoundELSE) {
          th("#else duplicated");
        } else {
          req.bFoundELSE = true;
        }
        req.bAlive = req.bChainAlive;
        break;
      // log ">>> else: name=#{req.name} bChainAlive=#{req.bChainAlive} bAlive=#{req.bAlive}"
      case line.slice(0, 6) !== "#endif":
        if (OUTPUT) {
          // log ">>> endif: name=#{req.name} bChainAlive=#{req.bChainAlive} bAlive=#{req.bAlive}"
          a.push(line);
        }
        if (stack.length > 0) {
          // return to requirements before first #if of this current chain was encountered
          req = stack.pop();
        } else {
          th("#endif without #if");
        }
        break;
      case line.slice(0, 7) !== "#import":
        if (req.bAlive) {
          if (OUTPUT) {
            a.push(line);
          }
          name = arg(line);
          if (name === "UT" && !ENV.ut) {
            a.push("# UT import is disabled");
          } else {
            if (ENV.server) {
              out = `${name} = require './Flexbase/${name}'`;
            } else if (ENV.node) {
              out = `${name} = require './${name}'`;
            } else if (ENV.rn) {
              out = `import ${name} from './${name}';`;
            } else {
              th("#import: neither node nor rn");
            }
            a.push(out);
          }
        }
        break;
      case line.slice(0, 8) !== "#IMPORT ":
        if (req.bAlive) {
          if (OUTPUT) {
            a.push(line);
          }
          name = arg(line);
          if (ENV.server) {
            out = `${name} = require './Flexbase/${name}'`;
          } else if (ENV.node) {
            out = `${name} = require './${name}'`;
          } else if (ENV.rn) {
            out = `import ${name} from './${name}';`;
          } else {
            th("#import: neither node nor rn");
          }
          a.push(out);
          a.push("abort=Context.abort");
          a.push("BB=Context.BB; GG=Context.GG; HM=Context.HM");
          a.push("KT=Context.kt; KVT=Context.kvt; VT=Context.vt");
          a.push("modMap=Context.modMap");
          a.push("ANEW=modMap.ANEW; ASS=modMap.ASS; C=modMap.C; DATE=modMap.DATE; IS=modMap.IS; NNEW=modMap.NNEW; ONEW=modMap.ONEW; SNEW=modMap.SNEW; textFormat=modMap.textFormat; VNEW=modMap.VNEW");
          a.push("duck=VNEW.duck; drill=ONEW.drill; json=VNEW.json");
        }
        break;
      case line.slice(0, 7) !== "#export":
        if (req.bAlive) {
          //					a.push line if OUTPUT
          name = arg(line);
          if (name === "UT" && !ENV.ut) {
            a.push("# UT import is disabled");
          } else {
            if (ENV.node) {
              out = `module.exports = ${name}`;
            } else if (ENV.rn) {
              out = `export default ${name};`;
            } else {
              th("#export: neither node nor rn");
            }
            a.push(out);
          }
        }
        break;
      default:
        //				console.log "@@@@@@@@@@ #{req.bAlive} => #{line}"
        if (req.bAlive) {
          a.push(PROC(line, ENV));
        }
    }
  }
  if (req.bFoundIF) {
    //		throw new Error "line=#{lineNbr+1} #endif missing: #{JSON.stringify stack}"
    //		throw new Error "line=#{lineNbr+1} #endif missing: #{JSON.stringify stack.forEach((o) -> o.name)}"
    throw new Error(`line=${lineNbr + 1} #endif missing: "${req.name}"`);
  }
  if (false) { //POPULAR
    for (lineNbr = k = 0, len1 = a.length; k < len1; lineNbr = ++k) {
      line = a[lineNbr];
      lg(`AFTER: LINE ${lineNbr + 1}: ${line}`);
    }
  }
  //	"# IF-COFFEE: ENV=#{JSON.stringify ENV}\n" + a.join '\n'
  return a.join('\n');
};

PROC = function(line, ENV, spath) {
  //	console.log "PROC: #{JSON.stringify ENV}:#{line} "

  //	if line.length is 0
  //		if ENV.rn
  //			line = "#DO_NOT_EDIT"
  //	else
  if (line.length > 0) {
    if (line.includes('#')) {
      line = line.replace(/\#RECENT.*/g, "");
      line = line.replace(/\#TODO.*/g, "");
      line = line.replace(/\#PREV.*/g, "");
      line = line.replace(/\#HERE.*/g, "");
    }
  }
  return line;
};

//	if line.includes "?"
//		line	#+ "!"
//	else
//		line
module.exports = {
  //if ut
  s_ut: function(_OUTPUT) {
    var PeterUT, UT;
    OUTPUT = _OUTPUT;
    UT = require('./UT');
    return (new (PeterUT = class PeterUT extends UT {
      run() {
        return this.s("process", function() {
          var fn, removePeriod;
          removePeriod = function(code) {
            var j, len, line, lineNbr, lines;
            lines = code.split('\n');
            for (lineNbr = j = 0, len = lines.length; j < len; lineNbr = ++j) {
              line = lines[lineNbr];
              if (line.length > 0 && line[0] === '.') {
                lines[lineNbr] = line.slice(1);
              }
            }
            return lines.join('\n');
          };
          fn = (c1, c2, ENV, that) => {
            var rv;
            c1 = removePeriod(c1);
            c2 = removePeriod(c2);
            //						console.log "====================BEFORE================ ENV=#{JSON.stringify ENV}"
            //						console.log c1
            //						console.log "-----------------------------------------------"
            //						console.log c2
            //						console.log "-----------------------------------------------"
            rv = process(c1, ENV);
            return that.eq(rv, c2);
          };
          this.t("trivial", function() {
            var c1, c2;
            c1 = ".abc\n.def";
            c2 = ".abc\n.def";
            return fn(c1, c2, {}, this);
          });
          this.t("if: env=", function() {
            var c1, c2;
            c1 = ".before\n.#if rn\n.this is rn\n.#else\n.this is NOT rn\n.#endif\n.after";
            c2 = ".before\n.this is NOT rn\n.after";
            return fn(c1, c2, {}, this);
          });
          this.t("if 0", function() {
            var c1, c2;
            c1 = ".#if 0\n.NO\n.#else\n.YES\n.#endif";
            c2 = ".YES";
            return fn(c1, c2, {}, this);
          });
          this.t("if 1", function() {
            var c1, c2;
            c1 = ".#if 1\n.YES\n.#else\n.NO\n.#endif";
            c2 = ".YES";
            return fn(c1, c2, {}, this);
          });
          this.t("if: env=rn", function() {
            var c1, c2;
            c1 = ".before\n.#if rn\n.this is rn\n.#else\n.this is NOT rn\n.#endif\n.after";
            c2 = ".before\n.this is rn\n.after";
            return fn(c1, c2, {
              rn: true
            }, this);
          });
          this.t("#elseif: case 1  (chain #if rn)", function() {
            var c1, c2;
            c1 = ".before\n.#if rn\n.rn\n.#elseif node\n.node\n.#else\n.else\n.#endif\n.after";
            c2 = ".before\n.rn\n.after";
            return fn(c1, c2, {
              rn: true,
              node: true
            }, this);
          });
          this.t("#elseif: case 2 (chain #elseif node)", function() {
            var c1, c2;
            c1 = ".before\n.#if rn\n.this is rn\n.#elseif node\n.this is node\n.#else\n.neither\n.#endif\n.after";
            c2 = ".before\n.this is node\n.after";
            return fn(c1, c2, {
              rn: false,
              node: true
            }, this);
          });
          this.t("#elseif: case 3 (chain #else)", function() {
            var c1, c2;
            c1 = ".before\n.#if rn\n.this is rn\n.#elseif node\n.this is node\n.#else\n.neither\n.#endif\n.after";
            c2 = ".before\n.neither\n.after";
            return fn(c1, c2, {
              rn: false,
              node: false
            }, this);
          });
          this.t("#else followed by #elseif", {
            exceptionMessage: "line=6: depth=1 name=rn: #elseif following #else"
          }, function() {
            var c1;
            c1 = ".before\n.#if rn\n.this is rn\n.#else\n.neither\n.#elseif node\n.this is node\n.#endif\n.after";
            return fn(c1, "", {
              rn: true,
              node: true
            }, this);
          });
          this.t("nested if: env=node", function() {
            var c1, c2;
            c1 = ".before\n.#if rn\n.this is rn\n.#else\n.this is NOT rn\n.#if node\n.this is node\n.#else\n.this is NOT node\n.#endif\n.#endif\n.after";
            c2 = ".before\n.this is NOT rn\n.this is node\n.after";
            return fn(c1, c2, {
              node: true
            }, this);
          });
          this.t("nested if: both false", function() {
            var c1, c2;
            c1 = ".before\n.#if rn\n.this is rn\n.#else\n.this is NOT rn\n.#if node\n.this is node\n.#else\n.this is NOT node\n.#endif\n.#endif\n.after";
            c2 = ".before\n.this is NOT rn\n.this is NOT node\n.after";
            return fn(c1, c2, {}, this);
          });
          this.t("nested if: breaks", function() {
            var c1, c2;
            c1 = ".before\n.#if rn\n.this is rn\n.#else\n.this is NOT rn\n.#if node\n.this is node\n.#else\n.this is NOT node\n.#endif\n.#endif\n.after";
            c2 = ".before\n.this is rn\n.after";
            return fn(c1, c2, {
              rn: true
            }, this);
          });
          this.t("double #if", function() {
            var c1, c2;
            c1 = ".before\n.#if rn\n.rn\n.#if node\n.node\n.#else\n.NOT node\n.#endif\n.between\n.#endif\n.after";
            c2 = ".before\n.rn\n.NOT node\n.between\n.after";
            return fn(c1, c2, {
              rn: true,
              node: false
            }, this);
          });
          this.t("double #if address real issue", function() {
            var c1, c2;
            c1 = ".before\n.#if ut\n.ut\n.#if node\n.ut node\n.#elseif rn\n.ut !node rn\n.#endif\n.between\n.#endif\n.after";
            c2 = ".before\n.after";
            return fn(c1, c2, {
              ut: false,
              node: false,
              rn: true
            }, this);
          });
          this.t("double #if: just added: make sure not covered by another test", function() {
            var c1, c2;
            c1 = ".before\n.#if ut\n.ut\n.#if node\n.ut node\n.#elseif rn\n.ut !node rn\n.#endif\n#else\n.ut else\n.#endif\n.after";
            c2 = ".before\n.ut else\n.after";
            return fn(c1, c2, {
              ut: false,
              node: false,
              rn: true
            }, this);
          });
          this.t("NEG: #else", {
            exceptionMessage: "line=2: depth=0: #else without #if"
          }, function() {
            var c1;
            c1 = ".abc\n.#else\n.def";
            return fn(c1, "", {
              rn: true
            }, this);
          });
          this.t("NEG: #endif", {
            exceptionMessage: "line=2: depth=0: #endif without #if"
          }, function() {
            var c1;
            c1 = ".abc\n.#endif\n.def";
            return fn(c1, "", {
              rn: true
            }, this);
          });
          this.t("NEG: #else duplicated", {
            exceptionMessage: "line=6: depth=1 name=rn: #else duplicated"
          }, function() {
            var c1;
            c1 = ".before\n.#if rn\n.this is rn\n.#else\n.this is NOT rn\n.#else\n.after 2nd else\n.#endif\n.after";
            return fn(c1, "", {}, this);
          });
          this.t("NEG: #endif missing", {
            exceptionMessage: "line=6 #endif missing: \"rn\""
          }, function() {
            var c1;
            c1 = ".before\n.#if rn\n.this is rn\n.#else\n.this is NOT rn";
            return fn(c1, "", {}, this);
          });
          this.t("NEG: #endif missing (nested)", {
            exceptionMessage: "line=8 #endif missing: \"rn\""
          }, function() {
            var c1;
            c1 = ".before\n.#if rn\n.this is rn\n.#if ALONE\n.#else\n.this is NOT rn\n.#endif";
            return fn(c1, "", {}, this);
          });
          this.t("NEG: unknown name", {
            exceptionMessage: "line=1: depth=1 name=Michelle: unknown"
          }, function() {
            var c1;
            c1 = ".#if Michelle\n.inside\n.#endif";
            return fn(c1, "", {}, this);
          });
          
          //#if node
          //			trace = require './trace'
          //			V = require './V'
          //			O = require './O'
          //#else
          //			import trace from './trace';
          //			import V from './V';
          //			import O from './O';
          //#endif

          //#HERE
          //#TODO
          //#import trace
          //#import V
          //#import O

          //#if node
          //			module.exports = EXPORTED
          //#else
          //			export default EXPORTED
          //#endif

          this.t("#import #export (node)", function() {
            var c1, c2;
            c1 = ".#import V\n.#export EXPORTED";
            c2 = "V = require './V'\nmodule.exports = EXPORTED";
            return fn(c1, c2, {
              node: true
            }, this);
          });
          this.t("#import #export (rn)", function() {
            var c1, c2;
            c1 = ".#import V\n.#export EXPORTED";
            c2 = "import V from './V';\nexport default EXPORTED;";
            return fn(c1, c2, {
              rn: true
            }, this);
          });
          this._t("??", function() {
            var c1, c2;
            c1 = `console.log "${true != null ? true : {
              "true": "false"
            }} and that is it!"`;
            c2 = "HELP";
            return fn(c1, c2, {}, this);
          });
          return this.s("PROC", function() {
            this._t("PROC", function() {
              return this.eq(PROC("abc def ? hello there : test monkey", {}), "hello");
            });
            this.t("#RECENT", function() {
              return this.eq(PROC("abc#RECENTdef", {}), "abc");
            });
            return this._t("rn empty line", function() {
              return this.eq(PROC("", {
                rn: true
              }), "#DO_NOT_EDIT");
            });
          });
        });
      }

    })).run();
  },
  //endif
  process: process
};
