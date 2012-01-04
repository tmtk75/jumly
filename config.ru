require './app'

module Sinatra
  module Sprockets
    def self.configure(rack)
      rack.map '/assets' do
        env = ::Sprockets::Environment.new
        env.append_path 'assets/javascripts'
        env.append_path 'assets/stylesheets'
        env.append_path 'assets/images'
        env.append_path 'vendor'
        env.append_path 'views/javascripts'
        run env
      end
      
      rack.map '/specs' do
        env = ::Sprockets::Environment.new
        env.append_path 'spec'
        run env
      end
    end
  end
end

Sinatra::Sprockets.configure self

map '/' do
  run App
end
