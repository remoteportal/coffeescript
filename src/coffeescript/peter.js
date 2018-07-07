// coffeescript.js: Generated by CoffeeScript GITLAB/lib 2.3.0
var O, lg, log, process, trace;

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
  var a, arg, i, len, line, lineNbr, lines, name, ref, req, stack, th;
  //	log "process: ENV=#{JSON.stringify ENV}"
  code = code.toString();
  //	log "FILE: SRC1: #{code}\n"
  a = [];
  stack = [];
  arg = function(line) {
    var tokens;
    tokens = line.split(' ');
    //		log "arg: #{tokens[1]}"
    return tokens[1];
  };
  req = {
    bGo: true
  };
  lines = code.split('\n');
//TODO #EASY: add ifdef end
//TODO: add switch, elseif?
//TODO: residude comment: //if node
  for (lineNbr = i = 0, len = lines.length; i < len; lineNbr = ++i) {
    line = lines[lineNbr];
    //		line = line.replace /?harles/, 'Christmas'
    lg(`${lineNbr + 1} LINE: ${line}`);
    //SLOW
    th = function(msg) {
      throw new Error(`line=${lineNbr + 1}: depth=${stack.length}${(req.name ? ` name=${req.name}` : "")}: ${msg}`);
    };
    switch (false) {
      case line.slice(0, 3) !== "#if":
        //				log "IF: line=#{line}: #{req.bGo}"
        name = arg(line);
        // save current requirements for later
        stack.push(req);
        //CHALLENGE: why clone?  appears to break if just set req={}   !!!
        // clone (otherwise side offect of messing with requirements object just saved)
        req = Object.assign({}, req);
        // the default is that this #if section is DEAD.  BUT, if bGo is true, then not dead: we need to flip when it else
        req.bFlipOnElse = false;
        if (req.bGo) {
          req.name = name;
          req.bFlipOnElse = true;
          req.bFoundELSE = false;
          req.bFoundIF = true;
          if ((ref = req.name) !== "0" && ref !== "1" && ref !== "ut" && ref !== "node" && ref !== "rn" && ref !== "cs" && ref !== "bin") {
            th("unknown");
          }
          // only go if this target is one of the environments
          req.bGo = req.name === "0" ? false : !!ENV[req.name];
          req.bGo = req.name === "1" ? true : req.bGo;
        }
        break;
      //					log "IF: name=#{req.name} bGo=#{req.bGo}"
      case line.slice(0, 5) !== "#else":
        if (req.bFoundELSE) {
          th("#else duplicated");
        } else {
          req.bFoundELSE = true;
        }
        if (!req.bFoundIF) {
          th("#else without #if");
        }
        if (req.bFlipOnElse) {
          // we're alive, so flip... whatever the logic was, now it's the opposite
          req.bGo = !req.bGo;
        }
        break;
      case line.slice(0, 6) !== "#endif":
        if (stack.length > 0) {
          req = stack.pop();
        } else {
          th("#endif without #if");
        }
        break;
      default:
        if (req.bGo) {
          a.push(line);
        }
    }
  }
  if (req.bFoundIF) {
    //		throw new Error "line=#{lineNbr+1} #endif missing: #{JSON.stringify stack}"
    //		throw new Error "line=#{lineNbr+1} #endif missing: #{JSON.stringify stack.forEach((o) -> o.name)}"
    throw new Error(`line=${lineNbr + 1} #endif missing: "${req.name}"`);
  }
  return a.join('\n');
};

//TODO: #elseif rn
module.exports = {
  //if ut
  s_ut: function() {
    var PeterUT, UT;
    UT = require('./UT');
    return (new (PeterUT = class PeterUT extends UT {
      run() {
        return this.s("process", function() {
          var fn, removePeriod;
          removePeriod = function(code) {
            var i, len, line, lineNbr, lines;
            lines = code.split('\n');
            for (lineNbr = i = 0, len = lines.length; i < len; lineNbr = ++i) {
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
          this.t("nested if: env=node", function() {
            var c1, c2;
            c1 = ".before\n.#if rn\n.this is rn\n.#else\n.this is NOT rn\n.#if node\n.this is emily\n.#else\n.this is NOT emily\n.#endif\n.#endif\n.after";
            c2 = ".before\n.this is NOT rn\n.this is emily\n.after";
            return fn(c1, c2, {
              node: true
            }, this);
          });
          this.t("#else", {
            exceptionMessage: "line=2: depth=0: #else without #if"
          }, function() {
            var c1;
            c1 = ".abc\n.#else\n.def";
            return fn(c1, "", {
              rn: true
            }, this);
          });
          this.t("#endif", {
            exceptionMessage: "line=2: depth=0: #endif without #if"
          }, function() {
            var c1;
            c1 = ".abc\n.#endif\n.def";
            return fn(c1, "", {
              rn: true
            }, this);
          });
          this.t("#else duplicated", {
            exceptionMessage: "line=6: depth=1 name=rn: #else duplicated"
          }, function() {
            var c1;
            c1 = ".before\n.#if rn\n.this is rn\n.#else\n.this is NOT rn\n.#else\n.after 2nd else\n.#endif\n.after";
            return fn(c1, "", {}, this);
          });
          this.T("#endif missing", {
            exceptionMessage: "line=6 #endif missing: \"rn\""
          }, function() {
            var c1;
            c1 = ".before\n.#if rn\n.this is rn\n.#else\n.this is NOT rn";
            return fn(c1, "", {}, this);
          });
          this.t("#endif missing (nested)", {
            exceptionMessage: "line=8 #endif missing: \"rn\""
          }, function() {
            var c1;
            c1 = ".before\n.#if rn\n.this is rn\n.#if ALONE\n.#else\n.this is NOT rn\n.#endif";
            return fn(c1, "", {}, this);
          });
          return this.T("unknown name", {
            exceptionMessage: "line=1: depth=1 name=Michelle: unknown"
          }, function() {
            var c1;
            c1 = ".#if Michelle\n.inside\n.#endif";
            return fn(c1, "", {}, this);
          });
        });
      }

    })).run();
  },
  //endif
  process: process
};
