require 'rubygems'
require 'haml'
def haml(x)
  Haml::Engine.new(File.read x.to_s + ".haml").render
end
