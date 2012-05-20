dir = "../assets/javascripts"
require "#{dir}/jquery-ext"
require "#{dir}/jquery-g2d"
JUMLY = (require "#{dir}/core").JUMLY
require "#{dir}/0.1.0"
require "#{dir}/common"
require "#{dir}/usecase"
require "#{dir}/class"
require "#{dir}/sequence"
require "#{dir}/plugin"

console.log "Loaded successfully."

exports.JUMLY = JUMLY 
global.JUMLY = JUMLY
global.CoffeeScript = require "coffee-script" 
