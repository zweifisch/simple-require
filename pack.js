// Generated by CoffeeScript 1.4.0
(function() {
  var concatScripts, configFile, fs, getDependencyTree, minify, output, parseFileList, path, program, scanForRequire, uglifyjs;

  fs = require('fs');

  path = require('path');

  program = require('commander');

  uglifyjs = require('uglify-js');

  program.version('0.0.1').option('--concat-scripts <file>', 'concat scripts list in <file>').option('--list-dependency <file>', 'list dependencies of a script').option('--build <file>', 'concat the script with all it\'s dependencies').option('--minify', 'minify the concated script using uglifyjs').parse(process.argv);

  parseFileList = function(filename) {
    var basedir, scripts;
    basedir = path.dirname(filename);
    return scripts = fs.readFileSync(filename, 'utf-8').split("\n").filter(function(x) {
      return x.length > 0 && x[0] !== '#';
    }).map(function(x) {
      return [x, path.join(basedir, "" + x + ".js")];
    });
  };

  concatScripts = function(scriptFiles) {
    var required, scripts;
    required = {};
    scripts = scriptFiles.map(function(_arg) {
      var filename, key, script;
      key = _arg[0], filename = _arg[1];
      if (!(key in required)) {
        script = fs.readFileSync(filename, 'utf-8');
        return "(function(require){\n	exports = {};\n	module = {exports:exports};\n	(function(exports,module,require){\n		" + script + "\n	})(exports,module,require);\n	require.required[\"" + key + "\"] = exports;\n})(window.require)";
      }
    });
    return "window.require = function(key){\n	return require.required[key];\n}\nwindow.require.required = {};\n" + (scripts.join("\n"));
  };

  scanForRequire = function(content) {
    var result;
    return result = /\s*require\s*\(\s*['"]([a-zA-Z0-9._-])['"]\s*\)/.match(content);
  };

  getDependencyTree = function(filename) {};

  minify = function(input) {
    var minified;
    minified = uglifyjs.minify(input, {
      fromString: true
    });
    return minified.code;
  };

  if (program.concatScripts) {
    configFile = program.concatScripts;
    if (!fs.existsSync(configFile)) {
      console.log("" + configFile + " not found");
      process.exit(1);
    }
    output = concatScripts(parseFileList(program.concatScripts));
    if (program.minify) {
      output = minify(output);
    }
    process.stdout.write(output);
  }

}).call(this);
