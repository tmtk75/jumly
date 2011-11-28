require "bundler"
Bundler.require

$js_dir  = "/assets"
$css_dir = "/assets"
$vendor_dir = "/assets"

class App < Sinatra::Base
  if development?
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  get '/'     do haml :"index.html" end
  get '/spec' do haml File.read "spec/index.html.haml" end
  get '/*'    do |n| haml :"#{n}" end

  helpers do
  end
end

