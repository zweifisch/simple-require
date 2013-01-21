# simple-require

nodejs style dependency management for browser

## how to use

suposing following project structure
```
index.html
main.js
lib
	my-math-helpers.js
	my-time-helpers.js
vender
	simplre-require.js
```

include `simplre-require.js`, `data-main="main"` here specifies the entry scripts `main.js`
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
var math = require('./my-math-helpers')
exports.getTimestamp = function(){
	return math.divide(+new Date(),1000);
}
```

finally `main.js`
```javascript
var time = require('./lib/my-math-helpers');
console.log(time.getTimestamp());
```

## why use it

* code sharing between browser and nodejs made easy
* simplicity(about 70 lines of coffeescript)

## how to pack

TBD

