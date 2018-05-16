// Generated by CoffeeScript 2.3.0
  // The `coffee` utility. Handles command-line compilation of CoffeeScript
  // into various forms: saved into `.js` files or printed to stdout
  // or recompiled every time the source is saved,
  // printed as a token stream or as the syntax tree, or launch an
  // interactive REPL.

  // External dependencies.
var BANNER, CoffeeScript, EventEmitter, NODE, SWITCHES, buildCSOptionParser, compileJoin, compileOptions, compilePath, compileScript, compileStdio, exec, findDirectoryIndex, forkNode, fs, helpers, hidden, joinTimeout, makePrelude, mkdirp, notSources, optionParser, optparse, opts, outputPath, parseOptions, path, printLine, printTokens, printWarn, removeSource, removeSourceDir, silentUnlink, sourceCode, sources, spawn, timeLog, usage, useWinPathSep, version, wait, watch, watchDir, watchedDirs, writeJs,
  indexOf = [].indexOf;

fs = require('fs');

path = require('path');

helpers = require('./helpers');

optparse = require('./optparse');

CoffeeScript = require('./');

({spawn, exec} = require('child_process'));

({EventEmitter} = require('events'));

useWinPathSep = path.sep === '\\';

// Allow CoffeeScript to emit Node.js events.
helpers.extend(CoffeeScript, new EventEmitter);

printLine = function(line) {
  return process.stdout.write(line + '\n');
};

printWarn = function(line) {
  return process.stderr.write(line + '\n');
};

hidden = function(file) {
  return /^\.|~$/.test(file);
};

// The help banner that is printed in conjunction with `-h`/`--help`.
BANNER = 'Usage: coffee [options] path/to/script.coffee [args]\n\nIf called without options, `coffee` will run your script.';

// The list of all the valid option flags that `coffee` knows how to handle.
SWITCHES = [['-b', '--bare', 'compile without a top-level function wrapper'], ['-c', '--compile', 'compile to JavaScript and save as .js files'], ['-e', '--eval', 'pass a string from the command line as input'], ['-h', '--help', 'display this help message!'], ['-i', '--interactive', 'run an interactive CoffeeScript REPL'], ['-j', '--join [FILE]', 'concatenate the source CoffeeScript before compiling'], ['-m', '--map', 'generate source map and save as .js.map files'], ['-M', '--inline-map', 'generate source map and include it directly in output'], ['-N', '--node', 'NODE output'], ['-n', '--nodes', 'print out the parse tree that the parser produces'], ['--nodejs [ARGS]', 'pass options directly to the "node" binary'], ['--no-header', 'suppress the "Generated by" header'], ['-o', '--output [PATH]', 'set the output path or path/filename for compiled JavaScript'], ['-p', '--print', 'print out the compiled JavaScript'], ['-r', '--require [MODULE*]', 'require the given module before eval or REPL'], ['-s', '--stdio', 'listen for and compile scripts over stdio'], ['-l', '--literate', 'treat stdio as literate style coffeescript'], ['-t', '--transpile', 'pipe generated JavaScript through Babel'], ['--tokens', 'print out the tokens that the lexer/rewriter produce'], ['-v', '--version', 'display the version number'], ['-w', '--watch', 'watch scripts for changes and rerun commands']];

// Top-level objects shared by all the functions.
opts = {};

sources = [];

sourceCode = [];

notSources = {};

watchedDirs = {};

optionParser = null;

exports.buildCSOptionParser = buildCSOptionParser = function() {
  return new optparse.OptionParser(SWITCHES, BANNER);
};

// Run `coffee` by parsing passed options and determining what action to take.
// Many flags cause us to divert before compiling anything. Flags passed after
// `--` will be passed verbatim to your script as arguments in `process.argv`
exports.run = function() {
  var err, i, len, literals, outputBasename, ref, replCliOpts, results, source;
  optionParser = buildCSOptionParser();
  try {
    parseOptions();
  } catch (error) {
    err = error;
    console.error(`option parsing error: ${err.message}`);
    process.exit(1);
  }
  if ((!opts.doubleDashed) && (opts.arguments[1] === '--')) {
    printWarn('coffee was invoked with \'--\' as the second positional argument, which is\nnow deprecated. To pass \'--\' as an argument to a script to run, put an\nadditional \'--\' before the path to your script.\n\n\'--\' will be removed from the argument list.');
    printWarn(`The positional arguments were: ${JSON.stringify(opts.arguments)}`);
    opts.arguments = [opts.arguments[0]].concat(opts.arguments.slice(2));
  }
  // Make the REPL *CLI* use the global context so as to (a) be consistent with the
  // `node` REPL CLI and, therefore, (b) make packages that modify native prototypes
  // (such as 'colors' and 'sugar') work as expected.
  replCliOpts = {
    useGlobal: true
  };
  if (opts.require) {
    opts.prelude = makePrelude(opts.require);
  }
  replCliOpts.prelude = opts.prelude;
  replCliOpts.transpile = opts.transpile;
  if (opts.nodejs) {
    return forkNode();
  }
  if (opts.help) {
    return usage();
  }
  if (opts.version) {
    return version();
  }
  if (opts.node) {
    return NODE();
  }
  if (opts.interactive) {
    return require('./repl').start(replCliOpts);
  }
  if (opts.stdio) {
    return compileStdio();
  }
  if (opts.eval) {
    return compileScript(null, opts.arguments[0]);
  }
  if (!opts.arguments.length) {
    return require('./repl').start(replCliOpts);
  }
  literals = opts.run ? opts.arguments.splice(1) : [];
  process.argv = process.argv.slice(0, 2).concat(literals);
  process.argv[0] = 'coffee';
  if (opts.output) {
    outputBasename = path.basename(opts.output);
    if (indexOf.call(outputBasename, '.') >= 0 && (outputBasename !== '.' && outputBasename !== '..') && !helpers.ends(opts.output, path.sep)) {
      // An output filename was specified, e.g. `/dist/scripts.js`.
      opts.outputFilename = outputBasename;
      opts.outputPath = path.resolve(path.dirname(opts.output));
    } else {
      // An output path was specified, e.g. `/dist`.
      opts.outputFilename = null;
      opts.outputPath = path.resolve(opts.output);
    }
  }
  if (opts.join) {
    opts.join = path.resolve(opts.join);
    console.error('\nThe --join option is deprecated and will be removed in a future version.\n\nIf for some reason it\'s necessary to share local variables between files,\nreplace...\n\n    $ coffee --compile --join bundle.js -- a.coffee b.coffee c.coffee\n\nwith...\n\n    $ cat a.coffee b.coffee c.coffee | coffee --compile --stdio > bundle.js\n');
  }
  ref = opts.arguments;
  results = [];
  for (i = 0, len = ref.length; i < len; i++) {
    source = ref[i];
    source = path.resolve(source);
    results.push(compilePath(source, true, source));
  }
  return results;
};

makePrelude = function(requires) {
  return requires.map(function(module) {
    var full, match, name;
    if (match = module.match(/^(.*)=(.*)$/)) {
      [full, name, module] = match;
    }
    name || (name = helpers.baseFileName(module, true, useWinPathSep));
    return `global['${name}'] = require('${module}')`;
  }).join(';');
};

// Compile a path, which could be a script or a directory. If a directory
// is passed, recursively compile all '.coffee', '.litcoffee', and '.coffee.md'
// extension source files in it and all subdirectories.
compilePath = function(source, topLevel, base) {
  var code, err, file, files, i, j, len, len1, line, lines, results, stats;
  if (indexOf.call(sources, source) >= 0 || watchedDirs[source] || !topLevel && (notSources[source] || hidden(source))) {
    return;
  }
  try {
    stats = fs.statSync(source);
  } catch (error) {
    err = error;
    if (err.code === 'ENOENT') {
      console.error(`File not found: ${source}`);
      process.exit(1);
    }
    throw err;
  }
  if (stats.isDirectory()) {
    if (path.basename(source) === 'node_modules') {
      notSources[source] = true;
      return;
    }
    if (opts.run) {
      compilePath(findDirectoryIndex(source), topLevel, base);
      return;
    }
    if (opts.watch) {
      watchDir(source, base);
    }
    try {
      files = fs.readdirSync(source);
    } catch (error) {
      err = error;
      if (err.code === 'ENOENT') {
        return;
      } else {
        throw err;
      }
    }
    results = [];
    for (i = 0, len = files.length; i < len; i++) {
      file = files[i];
      results.push(compilePath(path.join(source, file), false, base));
    }
    return results;
  } else if (topLevel || helpers.isCoffee(source)) {
    sources.push(source);
    sourceCode.push(null);
    delete notSources[source];
    if (opts.watch) {
      watch(source, base);
    }
    try {
      code = fs.readFileSync(source);
    } catch (error) {
      err = error;
      if (err.code === 'ENOENT2') {
        return;
      } else {
        throw err;
      }
    }
    code = code.toString();
    process.stdout.write(`FILE: ${code}`);
    lines = code.split('\n');
    for (j = 0, len1 = lines.length; j < len1; j++) {
      line = lines[j];
      process.stdout.write(`LINE: ${line}\n`);
    }
    process.stdout.write(`FILE: ${code}`);
    return compileScript(source, code, base);
  } else {
    return notSources[source] = true;
  }
};

findDirectoryIndex = function(source) {
  var err, ext, i, index, len, ref;
  ref = CoffeeScript.FILE_EXTENSIONS;
  for (i = 0, len = ref.length; i < len; i++) {
    ext = ref[i];
    index = path.join(source, `index${ext}`);
    try {
      if ((fs.statSync(index)).isFile()) {
        return index;
      }
    } catch (error) {
      err = error;
      if (err.code !== 'ENOENT') {
        throw err;
      }
    }
  }
  console.error(`Missing index.coffee or index.litcoffee in ${source}`);
  return process.exit(1);
};

// Compile a single source script, containing the given code, according to the
// requested options. If evaluating the script directly, set `__filename`,
// `__dirname` and `module.filename` to be correct relative to the script's path.
compileScript = function(file, input, base = null) {
  var compiled, err, message, options, saveTo, task;
  options = compileOptions(file, base);
  try {
    task = {file, input, options};
    CoffeeScript.emit('compile', task);
    if (opts.tokens) {
      return printTokens(CoffeeScript.tokens(task.input, task.options));
    } else if (opts.nodes) {
      return printLine(CoffeeScript.nodes(task.input, task.options).toString().trim());
    } else if (opts.run) {
      CoffeeScript.register();
      if (opts.prelude) {
        CoffeeScript.eval(opts.prelude, task.options);
      }
      return CoffeeScript.run(task.input, task.options);
    } else if (opts.join && task.file !== opts.join) {
      if (helpers.isLiterate(file)) {
        task.input = helpers.invertLiterate(task.input);
      }
      sourceCode[sources.indexOf(task.file)] = task.input;
      return compileJoin();
    } else {
      compiled = CoffeeScript.compile(task.input, task.options);
      task.output = compiled;
      if (opts.map) {
        task.output = compiled.js;
        task.sourceMap = compiled.v3SourceMap;
      }
      CoffeeScript.emit('success', task);
      if (opts.print) {
        return printLine(task.output.trim());
      } else if (opts.compile || opts.map) {
        saveTo = opts.outputFilename && sources.length === 1 ? path.join(opts.outputPath, opts.outputFilename) : options.jsPath;
        return writeJs(base, task.file, task.output, saveTo, task.sourceMap);
      }
    }
  } catch (error) {
    err = error;
    CoffeeScript.emit('failure', err, task);
    if (CoffeeScript.listeners('failure').length) {
      return;
    }
    message = (err != null ? err.stack : void 0) || `${err}`;
    if (opts.watch) {
      return printLine(message + '\x07');
    } else {
      printWarn(message);
      return process.exit(1);
    }
  }
};

// Attach the appropriate listeners to compile scripts incoming over **stdin**,
// and write them back to **stdout**.
compileStdio = function() {
  var buffers, stdin;
  if (opts.map) {
    console.error('--stdio and --map cannot be used together');
    process.exit(1);
  }
  buffers = [];
  stdin = process.openStdin();
  stdin.on('data', function(buffer) {
    if (buffer) {
      return buffers.push(buffer);
    }
  });
  return stdin.on('end', function() {
    return compileScript(null, Buffer.concat(buffers).toString());
  });
};

// If all of the source files are done being read, concatenate and compile
// them together.
joinTimeout = null;

compileJoin = function() {
  if (!opts.join) {
    return;
  }
  if (!sourceCode.some(function(code) {
    return code === null;
  })) {
    clearTimeout(joinTimeout);
    return joinTimeout = wait(100, function() {
      return compileScript(opts.join, sourceCode.join('\n'), opts.join);
    });
  }
};

// Watch a source CoffeeScript file using `fs.watch`, recompiling it every
// time the file is updated. May be used in combination with other options,
// such as `--print`.
watch = function(source, base) {
  var compile, compileTimeout, err, prevStats, rewatch, startWatcher, watchErr, watcher;
  watcher = null;
  prevStats = null;
  compileTimeout = null;
  watchErr = function(err) {
    if (err.code !== 'ENOENT') {
      throw err;
    }
    if (indexOf.call(sources, source) < 0) {
      return;
    }
    try {
      rewatch();
      return compile();
    } catch (error) {
      removeSource(source, base);
      return compileJoin();
    }
  };
  compile = function() {
    clearTimeout(compileTimeout);
    return compileTimeout = wait(25, function() {
      return fs.stat(source, function(err, stats) {
        if (err) {
          return watchErr(err);
        }
        if (prevStats && stats.size === prevStats.size && stats.mtime.getTime() === prevStats.mtime.getTime()) {
          return rewatch();
        }
        prevStats = stats;
        return fs.readFile(source, function(err, code) {
          if (err) {
            return watchErr(err);
          }
          compileScript(source, code.toString(), base);
          return rewatch();
        });
      });
    });
  };
  startWatcher = function() {
    return watcher = fs.watch(source).on('change', compile).on('error', function(err) {
      if (err.code !== 'EPERM') {
        throw err;
      }
      return removeSource(source, base);
    });
  };
  rewatch = function() {
    if (watcher != null) {
      watcher.close();
    }
    return startWatcher();
  };
  try {
    return startWatcher();
  } catch (error) {
    err = error;
    return watchErr(err);
  }
};

// Watch a directory of files for new additions.
watchDir = function(source, base) {
  var err, readdirTimeout, startWatcher, stopWatcher, watcher;
  watcher = null;
  readdirTimeout = null;
  startWatcher = function() {
    return watcher = fs.watch(source).on('error', function(err) {
      if (err.code !== 'EPERM') {
        throw err;
      }
      return stopWatcher();
    }).on('change', function() {
      clearTimeout(readdirTimeout);
      return readdirTimeout = wait(25, function() {
        var err, file, files, i, len, results;
        try {
          files = fs.readdirSync(source);
        } catch (error) {
          err = error;
          if (err.code !== 'ENOENT') {
            throw err;
          }
          return stopWatcher();
        }
        results = [];
        for (i = 0, len = files.length; i < len; i++) {
          file = files[i];
          results.push(compilePath(path.join(source, file), false, base));
        }
        return results;
      });
    });
  };
  stopWatcher = function() {
    watcher.close();
    return removeSourceDir(source, base);
  };
  watchedDirs[source] = true;
  try {
    return startWatcher();
  } catch (error) {
    err = error;
    if (err.code !== 'ENOENT') {
      throw err;
    }
  }
};

removeSourceDir = function(source, base) {
  var file, i, len, sourcesChanged;
  delete watchedDirs[source];
  sourcesChanged = false;
  for (i = 0, len = sources.length; i < len; i++) {
    file = sources[i];
    if (!(source === path.dirname(file))) {
      continue;
    }
    removeSource(file, base);
    sourcesChanged = true;
  }
  if (sourcesChanged) {
    return compileJoin();
  }
};

// Remove a file from our source list, and source code cache. Optionally remove
// the compiled JS version as well.
removeSource = function(source, base) {
  var index;
  index = sources.indexOf(source);
  sources.splice(index, 1);
  sourceCode.splice(index, 1);
  if (!opts.join) {
    silentUnlink(outputPath(source, base));
    silentUnlink(outputPath(source, base, '.js.map'));
    return timeLog(`removed ${source}`);
  }
};

silentUnlink = function(path) {
  var err, ref;
  try {
    return fs.unlinkSync(path);
  } catch (error) {
    err = error;
    if ((ref = err.code) !== 'ENOENT' && ref !== 'EPERM') {
      throw err;
    }
  }
};

// Get the corresponding output JavaScript path for a source file.
outputPath = function(source, base, extension = ".js") {
  var basename, dir, srcDir;
  basename = helpers.baseFileName(source, true, useWinPathSep);
  srcDir = path.dirname(source);
  dir = !opts.outputPath ? srcDir : source === base ? opts.outputPath : path.join(opts.outputPath, path.relative(base, srcDir));
  return path.join(dir, basename + extension);
};

// Recursively mkdir, like `mkdir -p`.
mkdirp = function(dir, fn) {
  var mkdirs, mode;
  mode = 0o777 & ~process.umask();
  return (mkdirs = function(p, fn) {
    return fs.exists(p, function(exists) {
      if (exists) {
        return fn();
      } else {
        return mkdirs(path.dirname(p), function() {
          return fs.mkdir(p, mode, function(err) {
            if (err) {
              return fn(err);
            }
            return fn();
          });
        });
      }
    });
  })(dir, fn);
};

// Write out a JavaScript source file with the compiled code. By default, files
// are written out in `cwd` as `.js` files with the same name, but the output
// directory can be customized with `--output`.

// If `generatedSourceMap` is provided, this will write a `.js.map` file into the
// same directory as the `.js` file.
writeJs = function(base, sourcePath, js, jsPath, generatedSourceMap = null) {
  var compile, jsDir, sourceMapPath;
  sourceMapPath = `${jsPath}.map`;
  jsDir = path.dirname(jsPath);
  compile = function() {
    if (opts.compile) {
      if (js.length <= 0) {
        js = ' ';
      }
      if (generatedSourceMap) {
        js = `${js}\n//# sourceMappingURL=${helpers.baseFileName(sourceMapPath, false, useWinPathSep)}\n`;
      }
      fs.writeFile(jsPath, js, function(err) {
        if (err) {
          printLine(err.message);
          return process.exit(1);
        } else if (opts.compile && opts.watch) {
          return timeLog(`compiled ${sourcePath}`);
        }
      });
    }
    if (generatedSourceMap) {
      return fs.writeFile(sourceMapPath, generatedSourceMap, function(err) {
        if (err) {
          printLine(`Could not write source map: ${err.message}`);
          return process.exit(1);
        }
      });
    }
  };
  return fs.exists(jsDir, function(itExists) {
    if (itExists) {
      return compile();
    } else {
      return mkdirp(jsDir, compile);
    }
  });
};

// Convenience for cleaner setTimeouts.
wait = function(milliseconds, func) {
  return setTimeout(func, milliseconds);
};

// When watching scripts, it's useful to log changes with the timestamp.
timeLog = function(message) {
  return console.log(`${(new Date).toLocaleTimeString()} - ${message}`);
};

// Pretty-print a stream of tokens, sans location data.
printTokens = function(tokens) {
  var strings, tag, token, value;
  strings = (function() {
    var i, len, results;
    results = [];
    for (i = 0, len = tokens.length; i < len; i++) {
      token = tokens[i];
      tag = token[0];
      value = token[1].toString().replace(/\n/, '\\n');
      results.push(`[${tag} ${value}]`);
    }
    return results;
  })();
  return printLine(strings.join(' '));
};

// Use the [OptionParser module](optparse.html) to extract all options from
// `process.argv` that are specified in `SWITCHES`.
parseOptions = function() {
  var o;
  o = opts = optionParser.parse(process.argv.slice(2));
  o.compile || (o.compile = !!o.output);
  o.run = !(o.compile || o.print || o.map);
  return o.print = !!(o.print || (o.eval || o.stdio && o.compile));
};

// The compile-time options to pass to the CoffeeScript compiler.
compileOptions = function(filename, base) {
  var answer, cwd, jsDir, jsPath;
  if (opts.transpile) {
    try {
      // The user has requested that the CoffeeScript compiler also transpile
      // via Babel. We don’t include Babel as a dependency because we want to
      // avoid dependencies in general, and most users probably won’t be relying
      // on us to transpile for them; we assume most users will probably either
      // run CoffeeScript’s output without transpilation (modern Node or evergreen
      // browsers) or use a proper build chain like Gulp or Webpack.
      require('babel-core');
    } catch (error) {
      // Give appropriate instructions depending on whether `coffee` was run
      // locally or globally.
      if (require.resolve('.').indexOf(process.cwd()) === 0) {
        console.error('To use --transpile, you must have babel-core installed:\n  npm install --save-dev babel-core\nAnd you must save options to configure Babel in one of the places it looks to find its options.\nSee http://coffeescript.org/#transpilation');
      } else {
        console.error('To use --transpile with globally-installed CoffeeScript, you must have babel-core installed globally:\n  npm install --global babel-core\nAnd you must save options to configure Babel in one of the places it looks to find its options, relative to the file being compiled or to the current folder.\nSee http://coffeescript.org/#transpilation');
      }
      process.exit(1);
    }
    if (typeof opts.transpile !== 'object') {
      opts.transpile = {};
    }
    // Pass a reference to Babel into the compiler, so that the transpile option
    // is available for the CLI. We need to do this so that tools like Webpack
    // can `require('coffeescript')` and build correctly, without trying to
    // require Babel.
    opts.transpile.transpile = CoffeeScript.transpile;
    // Babel searches for its options (a `.babelrc` file, a `.babelrc.js` file,
    // a `package.json` file with a `babel` key, etc.) relative to the path
    // given to it in its `filename` option. Make sure we have a path to pass
    // along.
    if (!opts.transpile.filename) {
      opts.transpile.filename = filename || path.resolve(base || process.cwd(), '<anonymous>');
    }
  } else {
    opts.transpile = false;
  }
  answer = {
    filename: filename,
    literate: opts.literate || helpers.isLiterate(filename),
    bare: opts.bare,
    header: opts.compile && !opts['no-header'],
    transpile: opts.transpile,
    sourceMap: opts.map,
    inlineMap: opts['inline-map']
  };
  if (filename) {
    if (base) {
      cwd = process.cwd();
      jsPath = outputPath(filename, base);
      jsDir = path.dirname(jsPath);
      answer = helpers.merge(answer, {
        jsPath,
        sourceRoot: path.relative(jsDir, cwd),
        sourceFiles: [path.relative(cwd, filename)],
        generatedFile: helpers.baseFileName(jsPath, false, useWinPathSep)
      });
    } else {
      answer = helpers.merge(answer, {
        sourceRoot: "",
        sourceFiles: [helpers.baseFileName(filename, false, useWinPathSep)],
        generatedFile: helpers.baseFileName(filename, true, useWinPathSep) + ".js"
      });
    }
  }
  return answer;
};

// Start up a new Node.js instance with the arguments in `--nodejs` passed to
// the `node` binary, preserving the other options.
forkNode = function() {
  var args, i, len, nodeArgs, p, ref, signal;
  nodeArgs = opts.nodejs.split(/\s+/);
  args = process.argv.slice(1);
  args.splice(args.indexOf('--nodejs'), 2);
  p = spawn(process.execPath, nodeArgs.concat(args), {
    cwd: process.cwd(),
    env: process.env,
    stdio: [0, 1, 2]
  });
  ref = ['SIGINT', 'SIGTERM'];
  for (i = 0, len = ref.length; i < len; i++) {
    signal = ref[i];
    process.on(signal, (function(signal) {
      return function() {
        return p.kill(signal);
      };
    })(signal));
  }
  return p.on('exit', function(code) {
    return process.exit(code);
  });
};

// Print the `--help` usage message and exit. Deprecated switches are not
// shown.
usage = function() {
  return printLine(optionParser.help());
};

// Print the `--version` message and exit.
version = function() {
  return printLine(`CoffeeScript version ${CoffeeScript.VERSION} PETE2`);
};

NODE = function() {
  return printLine("ifdef node");
};
