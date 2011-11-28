module Jumly
  module Demo
    module Sequence
      COFFEE = {}
      [:restaurant, :applytheme, :osgi, :http, :httpreqres, :order].each {|e|
        COFFEE[e] = File.read "./views/javascripts/#{e}.js.coffee"
      }
    end
  end
end
