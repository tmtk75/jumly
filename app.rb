require "bundler"
Bundler.require

$js_dir  = "/assets"
$css_dir = "/assets"
$vendor_dir = "/assets"

$copyright_html = <<EOF
&copy;copyright 2011-#{Time.new.year}, Tomotaka Sakuma all rights reserved.
EOF

class App < Sinatra::Base
  if development?
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  get '/'       do haml :"index.html" end
  get '/spec'   do haml :"../spec/index.html" end
  get '/spec/*' do |n| haml :"../spec/index.html", :locals=>{:scripts=>[n]} end
  get '/*'      do |n| haml :"#{n}" end

  helpers do
  end
end
