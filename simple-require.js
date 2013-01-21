// Generated by CoffeeScript 1.4.0
(function() {
  var directRequire, dirname, entryScript, expose, getEntryScript, getRequire, getSync, getXHR, injectJS, joinPath, required,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty;

  required = {};

  joinPath = function() {
    var concat, notEmpty, parent, parts;
    parts = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    concat = function(done, part) {
      return done.concat(part.split('/'));
    };
    notEmpty = function(x) {
      return x.length > 0 && x !== '.';
    };
    parent = function(done, part) {
      if (part === '..') {
        done.pop();
      } else {
        done.push(part);
      }
      return done;
    };
    return parts.reduce(concat, []).filter(notEmpty).reduce(parent, []).join('/');
  };

  dirname = function(path) {
    var tokens, _, _i, _ref;
    _ref = path.split('/'), tokens = 2 <= _ref.length ? __slice.call(_ref, 0, _i = _ref.length - 1) : (_i = 0, []), _ = _ref[_i++];
    return joinPath.apply(null, tokens);
  };

  getXHR = function() {
    var ret;
    if (window.XMLHttpRequest) {
      ret = new XMLHttpRequest;
    } else {
      try {
        ret = new ActiveXObject('Msxml2.XMLHTTP');
      } catch (e) {
        ret = new ActiveXObject('Microsoft.XMLHTTP');
      }
    }
    return ret;
  };

  getSync = function(url) {
    var xhr;
    xhr = getXHR();
    xhr.open('GET', url, false);
    xhr.send('');
    return xhr;
  };

  injectJS = function(content) {
    var head, script;
    script = document.createElement('script');
    script.type = 'text/javascript';
    script.text = content;
    head = document.getElementsByTagName('head')[0];
    return head.appendChild(script);
  };

  expose = function(objects, block) {
    var conflicts, name, object;
    conflicts = {};
    for (name in objects) {
      if (!__hasProp.call(objects, name)) continue;
      object = objects[name];
      if (name in window) {
        conflicts[name] = window[name];
      }
      window[name] = object;
    }
    return block(function() {
      var _results;
      _results = [];
      for (name in objects) {
        if (!__hasProp.call(objects, name)) continue;
        if (name in conflicts) {
          _results.push(window[name] = object);
        } else {
          _results.push(delete window[name]);
        }
      }
      return _results;
    });
  };

  getRequire = function(currentPath) {
    return function(path) {
      path = joinPath(currentPath, path);
      if (!(path in required)) {
        directRequire(path);
      }
      return required[path];
    };
  };

  directRequire = function(path) {
    var exports, objects, result;
    exports = {};
    objects = {
      require: getRequire(dirname(path)),
      exports: exports,
      module: {
        exports: exports
      }
    };
    result = getSync("" + path + ".js");
    if (result.status !== 200) {
      throw {
        message: result.statusText
      };
      ({
        code: result.status
      });
    }
    return expose(objects, function(restore) {
      injectJS("(function(require,exports,module){\n	" + result.responseText + "\n})(require,exports,module)");
      restore();
      return required[path] = objects.module.exports;
    });
  };

  getEntryScript = function() {
    var script, _, _i, _ref;
    _ref = document.getElementsByTagName('script'), _ = 2 <= _ref.length ? __slice.call(_ref, 0, _i = _ref.length - 1) : (_i = 0, []), script = _ref[_i++];
    return script.getAttribute('data-main');
  };

  entryScript = getEntryScript();

  if (entryScript) {
    directRequire(entryScript);
  }

}).call(this);
