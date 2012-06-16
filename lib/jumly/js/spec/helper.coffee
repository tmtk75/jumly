has_window = (->
  try
    eval("window")
    true
  catch ex
    false)()

if has_window
  ;
else
  coffee = require "coffee-script" 
  require "node-jquery"
  dir = "../../js"
  #require "#{dir}/jquery-ext"
  #require "#{dir}/jquery-g2d"
  #core = (require "#{dir}/core.coffee")
  #require "#{dir}/0.1.0"
  #require "#{dir}/common"
  #require "#{dir}/usecase"
  #require "#{dir}/class"
  #require "#{dir}/sequence"
  #require "#{dir}/plugin"
  #global.CoffeeScript = coffee
  #global.JUMLY = core.JUMLY
