# simple-require

nodejs like require/exports for browser

## how to use

asumming following project structure
```
index.html
main.js
lib
	my-math-helpers.js
	my-time-helpers.js
vender
	simplre-require.js
```

include `simplre-require.js` in `index.html`, `data-main="main"` here claims that the entry script is `main.js`
```html
<script data-main="main" type="text/javascript" src="vender/simple-require.js"></script>
```

content of `lib/my-math-helpers.js`
```javascript
exports.version = 'v0.0.1';
exports.divide = function(n,n2){
	return Math.floor(n/n2);
}
```

content of `lib/my-time-helpers.js`
```javascript
var math = require('./my-math-helpers');
exports.getTimestamp = function(){
	return math.divide(+new Date(),1000);
}
```

finally `main.js`
```javascript
var time = require('./lib/my-time-helpers');
console.log(time.getTimestamp());
```

## why use it

* code sharing between browser and nodejs made easy
* simplicity(about 100 lines of coffeescript)

## how to pack

install simple-require via npm

```sh
npm install -g simple-require
```

```sh
simple-require --build main.js >! packed.js
```

there is also a `--minify` option, if set, the concated script will be passed
to uglify-js

### including libraries

prepare a text file with a list of libraries inside
```
vender/jquery
vender/some-other-lib
```

set the data-shims attribute
```html
<script type="text/javascript" src="vender/simple-require.js"
	data-main="main" data-shims="shims.txt"></script>
```

when packing scripts, use the `--shims` option

### more options

using `--list-dependency` or `-l` for short to list dependencies of a file
```sh
simple-require --list-dependency main.js
```

`--json` for json output, `--flat` for more simpler output

### pack manually

prepare a `build.txt`, the entry script must be placed at the top of it
```
main
lib/my-math-helper
lib/time-helper
```
then run
```sh
simple-require --concat-scripts build.txt >! build.js
```


