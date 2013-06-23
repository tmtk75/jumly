// $ heroku create --stack cedar
// $ heroku config:add NODE_ENV=heroku

/*
var cluster = require('cluster');
var prefork_count = require('os').cpus().length;

if (cluster.isMaster) {
  console.log("prefork-count:", prefork_count);
  for (var i = 0; i < prefork_count; i++) {
    cluster.fork();
  }
} else {
  var coffee = require('coffee-script');
  var fs = require('fs');
  var app = coffee.compile(fs.readFileSync('./app.coffee').toString());
  eval(app);
}
*/
var coffee = require('coffee-script');
var fs = require('fs');
var app = coffee.compile(fs.readFileSync('./app.coffee').toString());
eval(app);
