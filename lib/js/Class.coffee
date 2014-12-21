###
<div class="class icon">
  <span class="stereotype">abstract</span>
  <span class="name">UMLObject</span>
  <ul class="attrs">
    <li>name</li>
    <li>stereotypes</li>
  </ul>
  <ul class="methods">
    <li>activate</li>
    <li>isLeftAt(a)</li>
    <li>isRightAt(a)</li>
    <li>iconify(fixture, styles)</li>
    <li>lost</li>
  </ul>
</div>
###

HTMLElement = require "HTMLElement.coffee"

class Class extends HTMLElement

Class::_build_ = (div)->
  icon = $("<div>")
           .addClass("icon")
           .append($("<div>").addClass "stereotype")
           .append($("<div>").addClass "name")
           .append($("<ul>").addClass "attrs")
           .append($("<ul>").addClass "methods")
  div.addClass("object")
     .append(icon)

def = ->
#def ".class-diagram", ClassDiagram
def ".class", Class

if typeof module != 'undefined' and module.exports
  module.exports = Class
else
  require("core").Class = Class
