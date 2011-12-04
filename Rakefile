require 'rake/clean'
require 'rake/packagetask'
require 'bundler'
Bundler.require
require 'yui/compressor'

PROJECT_NAME = "jumly"
VERSION = (File.read "VERSION").strip
BASENAME = PROJECT_NAME
BUILD_DIR     = "build"
JS_BUILD_DIR  = "#{BUILD_DIR}/javascripts"
CSS_BUILD_DIR = "#{BUILD_DIR}/stylesheets"

namespace :compile do
  task :js do
    sh "coffee --bare -c -o #{JS_BUILD_DIR} assets/javascripts/*.coffee"
  end
  task :css do
    sh "sass --unix-newline --update --scss assets/stylesheets:#{CSS_BUILD_DIR}"
  end
end

namespace :unify do
  task :js do
    files = File.readlines("assets/javascripts/jumly.js")
                .map do |e| e.strip.gsub(%r#//\= *?require[a-z_]* #, "") end
                .map do |e| "#{JS_BUILD_DIR}/#{e}.js" end
    sh "cat #{files.compact.join ' '} > #{BUILD_DIR}/jumly.js"
  end
  task :css do
    sh "cat #{CSS_BUILD_DIR}/jumly.css > #{BUILD_DIR}/jumly.css"
  end
end

namespace :compress do
  task :js do
    minjs = ::YUI::JavaScriptCompressor.new.compress File.read "#{BUILD_DIR}/jumly.js"
    jsminpath = "#{BUILD_DIR}/jumly-#{VERSION}.min.js"
    open jsminpath, "w" do |f|
      f.write "// jumly-#{VERSION}, tomotaka.sakuma 2011 copryright(c), all rights reserved.\n"
      f.write minjs
    end
    sh "cp #{jsminpath} #{BUILD_DIR}/jumly.min.js"
    sh <<-EOF
    cd #{BUILD_DIR}
    shasum *.js > jumly.js.sha1
    EOF
  end
  task :css do
    mincss = ::YUI::CssCompressor.new.compress File.read "#{BUILD_DIR}/jumly.css"
    cssminpath = "#{BUILD_DIR}/jumly-#{VERSION}.min.css"
    open cssminpath, "w" do |f|
      f.write "/* jumly-#{VERSION}, tomotaka.sakuma 2011 copryright(c), all rights reserved. */\n"
      f.write mincss
    end
    sh "cp #{cssminpath} #{BUILD_DIR}/jumly.min.css"
    sh <<-EOF
    cd #{BUILD_DIR}
    shasum *.css > jumly.css.sha1
    EOF
  end
end

CLEAN.include ["pkg"]
Rake::PackageTask.new(PROJECT_NAME, VERSION) do |p|
  p.package_files.include "README.md"
  p.package_files.include "#{JS_BUILD_DIR}/#{BASENAME}-*min.js"
  p.package_files.include "#{CSS_BUILD_DIR}/#{BASENAME}-*min.css"
  p.package_files.include "vendor/*.js"
  p.need_tar_gz = true
end

task :default => [:compile, :unify, :compress]

desc "Compile coffeescript/scss"
task :compile => ["compile:js", "compile:css"]

desc "Unify javascript/css"
task :unify => ["unify:js", "unify:css"]

desc "Compress javascript/css"
task :compress => ["compress:js", "compress:css"]

desc "Make distribution package, compile, minify and package"
task :dist => [:default, :package]

