# simple-require

nodejs style dependency management for browser

## how does it look like

include it
```html
<script type="text/javascript" src="simple-require.js"></script>
<script type="text/javascript" src="main.js"></script>
```

write your lib `lib/my-math-helpers.js`
```javascript
exports.version = 'v0.0.1';
// module.exports is also supported
```

load it in `main.js`
```javascript
math = require('lib/my-math-helpers');
console.log(math.version);
```

## why use it

* code sharing between browser and nodejs made easy
* simplicity(less then 40 lines of coffeescript)

## the untold truth

it's *synchronous*(should be slow when involving multiple js files), 
you'd better pack the js files(in the right order) before deploy the app

## TODO

* relative path
