module Jumly
  module Demo
    module Sequence
      COFFEE = {}
      [:restaurant, :applytheme, :osgi, :http, :httpreqres, :order].each {|e|
        COFFEE[e] = File.read "#{Dir.pwd()}/views/javascripts/#{e}.coffee"
      }
    end
  end
end
