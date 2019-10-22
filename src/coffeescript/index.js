// Generated by CoffeeScript 2.4.1
(function() {
  // Node.js Implementation
  var CoffeeScript, ext, fs, helpers, i, len, path, ref, universalCompile, vm,
    hasProp = {}.hasOwnProperty;

  CoffeeScript = require('./coffeescript');

  fs = require('fs');

  vm = require('vm');

  path = require('path');

  helpers = CoffeeScript.helpers;

  CoffeeScript.transpile = function(js, options) {
    var babel;
    try {
      babel = require('babel-core');
    } catch (error) {
      // This error is only for Node, as CLI users will see a different error
      // earlier if they don’t have Babel installed.
      throw new Error('To use the transpile option, you must have the \'babel-core\' module installed');
    }
    return babel.transform(js, options);
  };

  // The `compile` method shared by the CLI, Node and browser APIs.
  universalCompile = CoffeeScript.compile;

  // The `compile` method particular to the Node API.
  CoffeeScript.compile = function(code, options) {
    // Pass a reference to Babel into the compiler, so that the transpile option
    // is available in the Node API. We need to do this so that tools like Webpack
    // can `require('coffeescript')` and build correctly, without trying to
    // require Babel.
    if (options != null ? options.transpile : void 0) {
      options.transpile.transpile = CoffeeScript.transpile;
    }
    //PETER #PATH: to compilation
    return universalCompile.call(CoffeeScript, code, options);
  };

  // Compile and execute a string of CoffeeScript (on the server), correctly
  // setting `__filename`, `__dirname`, and relative `require()`.
  CoffeeScript.run = function(code, options = {}) {
    var answer, dir, mainModule, ref;
    mainModule = require.main;
    // Set the filename.
    mainModule.filename = process.argv[1] = options.filename ? fs.realpathSync(options.filename) : '<anonymous>';
    // Clear the module cache.
    mainModule.moduleCache && (mainModule.moduleCache = {});
    // Assign paths for node_modules loading
    dir = options.filename != null ? path.dirname(fs.realpathSync(options.filename)) : fs.realpathSync('.');
    mainModule.paths = require('module')._nodeModulePaths(dir);
    // Save the options for compiling child imports.
    mainModule.options = options;
    // Compile.
    if (!helpers.isCoffee(mainModule.filename) || require.extensions) {
      answer = CoffeeScript.compile(code, options);
      code = (ref = answer.js) != null ? ref : answer;
    }
    return mainModule._compile(code, mainModule.filename);
  };

  // Compile and evaluate a string of CoffeeScript (in a Node.js-like environment).
  // The CoffeeScript REPL uses this to run the input.
  CoffeeScript.eval = function(code, options = {}) {
    var Module, _module, _require, createContext, i, isContext, js, k, len, o, r, ref, ref1, ref2, ref3, sandbox, v;
    if (!(code = code.trim())) {
      return;
    }
    createContext = (ref = vm.Script.createContext) != null ? ref : vm.createContext;
    isContext = (ref1 = vm.isContext) != null ? ref1 : function(ctx) {
      return options.sandbox instanceof createContext().constructor;
    };
    if (createContext) {
      if (options.sandbox != null) {
        if (isContext(options.sandbox)) {
          sandbox = options.sandbox;
        } else {
          sandbox = createContext();
          ref2 = options.sandbox;
          for (k in ref2) {
            if (!hasProp.call(ref2, k)) continue;
            v = ref2[k];
            sandbox[k] = v;
          }
        }
        sandbox.global = sandbox.root = sandbox.GLOBAL = sandbox;
      } else {
        sandbox = global;
      }
      sandbox.__filename = options.filename || 'eval';
      sandbox.__dirname = path.dirname(sandbox.__filename);
      // define module/require only if they chose not to specify their own
      if (!(sandbox !== global || sandbox.module || sandbox.require)) {
        Module = require('module');
        sandbox.module = _module = new Module(options.modulename || 'eval');
        sandbox.require = _require = function(path) {
          return Module._load(path, _module, true);
        };
        _module.filename = sandbox.__filename;
        ref3 = Object.getOwnPropertyNames(require);
        for (i = 0, len = ref3.length; i < len; i++) {
          r = ref3[i];
          if (r !== 'paths' && r !== 'arguments' && r !== 'caller') {
            _require[r] = require[r];
          }
        }
        // use the same hack node currently uses for their own REPL
        _require.paths = _module.paths = Module._nodeModulePaths(process.cwd());
        _require.resolve = function(request) {
          return Module._resolveFilename(request, _module);
        };
      }
    }
    o = {};
    for (k in options) {
      if (!hasProp.call(options, k)) continue;
      v = options[k];
      o[k] = v;
    }
    o.bare = true; // ensure return value
    js = CoffeeScript.compile(code, o);
    if (sandbox === global) {
      return vm.runInThisContext(js);
    } else {
      return vm.runInContext(js, sandbox);
    }
  };

  CoffeeScript.register = function() {
    return require('./register');
  };

  // Throw error with deprecation warning when depending upon implicit `require.extensions` registration
  if (require.extensions) {
    ref = CoffeeScript.FILE_EXTENSIONS;
    for (i = 0, len = ref.length; i < len; i++) {
      ext = ref[i];
      (function(ext) {
        var base;
        return (base = require.extensions)[ext] != null ? base[ext] : base[ext] = function() {
          throw new Error(`Use CoffeeScript.register() or require the coffeescript/register module to require ${ext} files.`);
        };
      })(ext);
    }
  }

  CoffeeScript._compileFile = function(filename, options = {}) {
    var answer, err, raw, stripped;
    raw = fs.readFileSync(filename, 'utf8');
    // Strip the Unicode byte order mark, if this file begins with one.
    stripped = raw.charCodeAt(0) === 0xFEFF ? raw.substring(1) : raw;
    options = Object.assign({}, options, {
      filename: filename,
      literate: helpers.isLiterate(filename),
      sourceFiles: [filename],
      inlineMap: true // Always generate a source map, so that stack traces line up.
    });
    try {
      answer = CoffeeScript.compile(stripped, options);
    } catch (error) {
      err = error;
      // As the filename and code of a dynamically loaded file will be different
      // from the original file compiled with CoffeeScript.run, add that
      // information to error so it can be pretty-printed later.
      throw helpers.updateSyntaxError(err, stripped, filename);
    }
    return answer;
  };

  module.exports = CoffeeScript;

}).call(this);
