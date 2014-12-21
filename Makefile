karma: coffee-script.js
	karma start karma.conf.js

coffee-script:
	curl -OL http://coffeescript.org/extras/coffee-script.js

jasmine:
	NODE_PATH=node_modules:lib/js jasmine-node --coffee spec/*.coffee
