lib = "../../js"
has_window = (-> try
    eval("window")
    true
  catch ex
    false)()

unless has_window
  coffee = require "coffee-script" 
  require "node-jquery"
  #require "#{lib}/jquery-ext"
  #require "#{lib}/jquery-g2d"
  #core = (require "#{lib}/core.coffee")
  #require "#{lib}/0.1.0"
  #require "#{lib}/common"
  #require "#{lib}/usecase"
  #require "#{lib}/class"
  #require "#{lib}/sequence"
  #require "#{lib}/plugin"
  #global.CoffeeScript = coffee
  #global.JUMLY = core.JUMLY
