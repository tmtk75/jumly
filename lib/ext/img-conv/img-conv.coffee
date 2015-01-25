system = require "system"
fs = require "fs"

### usage ###
if system.args.length < 2
  console.log """
    usage: #{system.args[0]} <script-path> [format] [encoding]
      script-path    meet-you.jm
      format         png | jpg
      encoding       image | base64 | html

    ex)
      #{system.args[0]} meet-you.jm jpg
      #{system.args[0]} meet-you.jm png base64

    """
  phantom.exit 1


### arguments ###
script_path = system.args[1]
format      = system.args[2] or "png"
encoding    = system.args[3] or "image"

regex_ext = /\.[^.]+$/
ext = if format.match /^(png|gif|jpg|jpeg)$/i then format else "png"
img_path =  if script_path.match regex_ext
              script_path.replace regex_ext, "." + ext
            else
              script_path + "." + ext
html_path = img_path.replace regex_ext, ".html"

##
phantom.onError = (msg, trace)->
  console.error 'PHANTOM ERROR:', msg
  phantom.exit 1

### read script ###
body = fs.read script_path
#console.log script_path, img_path, html_path


### run ###
require("./loadJUMLY").loadJUMLY body, (page)->
  ## create a file as .png
  if encoding.match /image/i
    page.render img_path
    console.log img_path

  ## print base64 to stdout
  console.log page.renderBase64 ext if encoding.match /^base64$/i

  ## print html to stdout
  if encoding.match /^html$/i
    console.log '<link rel="stylesheet" href="http://jumly.tmtk.net/public/jumly.min.css"/>'
    console.log page.evaluate -> $("body").html()

  ## create a file to show above it
  ###
  fs.write html_path, """
    <!DOCTYPE html>
    <style>body {background-color:#eee;}</style>
    <img src='#{img_path}'></img>
    """, "w"
  ###
  phantom.exit()
