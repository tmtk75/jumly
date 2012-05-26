// $ heroku create --stack cedar
var coffee = require('coffee-script');
var fs = require('fs');
var app = coffee.compile(fs.readFileSync('./app.coffee').toString());
eval(app);
