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
  var _, a, arg, bGo, compute, cur, i, j, k, len, line, lines, name, stack;
  //	log "process"
  code = code.toString();
  //	log "FILE: SRC1: #{code}\n"
  a = [];
  stack = [];
  name = null;
  arg = function(line) {
    var tokens;
    tokens = line.split(' ');
    //		log "arg: #{tokens[1]}"
    return tokens[1];
  };
  compute = function() {};
  cur = {};
  lines = code.split('\n');
  for (i = j = 0, len = lines.length; j < len; i = ++j) {
    line = lines[i];
    switch (false) {
      //		line = line.replace /Charles/, 'Christmas'
      case line.slice(0, 3) !== "#if":
        //				log line
        stack.push(cur);
        cur = Object.assign({}, cur);
        cur[name = arg(line)] = true;
        //				O.DUMP cur
        compute();
        break;
      case line.slice(0, 5) !== "#else":
        //				log line
        //				stack[stack.length-1][name] ^= true
        cur[name] ^= true;
        compute();
        break;
      case line.slice(0, 6) !== "#endif":
        //				log line
        cur = stack.pop();
        break;
      default:
        if (O.CNT_OWN(cur) === 0) {
          //					log "empty"
          a.push(line);
        } else {
          // make sure all requirements satisfied
          bGo = true;
          for (k in cur) {
            if (cur[k]) {
              bGo &= ENV[k];
            }
          }
          if (bGo) {
            a.push(line);
          }
        }
    }
  }
  //					else
  //						lg "SKIP: #{line}"
  //		lines[i] = line
  //		log "LINE: #{line}"
  _ = a.join('\n');
  //	log "========== AFTER"
  //	log _
  return _;
};

module.exports = {
  //if ut
  s_ut: function() {
    var PeterUT, UT;
    UT = require('./UT');
    return (new (PeterUT = class PeterUT extends UT {
      run() {
        return this.s("process", function() {
          var fn;
          fn = (c1, c2, ENV, that) => {
            var rv;
            console.log(`====================BEFORE================ ENV=${ENV}`);
            console.log(c1);
            console.log("-----");
            console.log(c2);
            rv = process(c1, c2, ENV);
            return that.eq(rv, c2);
          };
          this._t("simple", function() {
            var c1, c2;
            c1 = "one\ntwo\nthree";
            c2 = process(c1);
            return this.eq(c1, c2);
          });
          return this.t("if", function() {
            var c1, c2;
            c1 = "before\n#if rn\nthis is rn\n#endif\nafter";
            c2 = "before\nafter";
            return fn(c1, c2, {}, this);
          });
        });
      }

    })).run();
  },
  //endif
  process: process
};
