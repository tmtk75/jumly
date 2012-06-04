##
## NOTE: This file is expected to be loaded on browser
##       to support fake global and exports object of Node.js
##
window.global = window
window.exports = global
window.require = (a)-> console.error "require", a, "ignored"
