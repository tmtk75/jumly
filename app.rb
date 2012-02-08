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
  get '/README' do markdown :"../README" end
  post '/matag' do Helper.matag_for self, request end
  get '/examples/*' do |n| Helper.example_of self, n end
  get %r{/(.*?)\.([a-z]{2})$} do |bn, ext| haml :"#{bn}", :locals=>mklocals(bn, ext) end
  get '/*' do |n| haml :"#{n}", :locals=>mklocals(n, "en") end

  class Helper
    def self.example_of ctx, n
      ctx.content_type "text/jumly"
      File.new("views/examples/#{n}").read
    end
    def self.matag_for ctx, req
      ctx.content_type "application/json"
      tagger = Brill::Tagger.new
      tagger.tag(req.body.read).to_s
    end
  end

  class I18N
    require 'yaml'
    attr :ext
    def initialize(bn, ext)
      @res = {}
      @bn = bn
      @ext = ext
      fn = "views/_#{bn}.i18n"
      @res = YAML.load(File.read fn) if File.exist? fn
    end
    def _(k)
      return k unless @res
      r = @res[k.downcase]
      if r
        if r[@ext]
          r[@ext]
        else
          raise "NOT FOUND: i18n resource for '#{@ext}' of '#{k.downcase}' due to gritch on program." unless @ext == "en"
          k
        end
      else
        k
      end
    end
  end
  def mklocals(bn, ext)
    {i18n:I18N.new(bn, ext)}
  end
  helpers do
  end
end
