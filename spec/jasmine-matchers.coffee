root =
  setup: (suite)->
    suite.addMatchers
      haveClass: (expected)->
        @actual.hasClass expected

core = require "core"
if core.env.is_node
  global.jasmine_matchers = root
  module.exports = root
else
  core.exports root, "./jasmine-matchers"
