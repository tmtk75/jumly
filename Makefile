karma:
	karma start karma.conf.js

jasmine:
	NODE_PATH=node_modules:lib/js jasmine-node --coffee spec/*.coffee
