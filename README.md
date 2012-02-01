#  README

JUMLY is a JavaScript library.  
Using JUMLY, you can easily embed UML diagram on your HTML document.  
All you need are just two in order to use JUMLY.

- Text editor you get used to use.
- Modern browser like WebKit-base brwoser and Opera.  
  (planning it works on other browsers, especially Firefox.)


## Getting Started
Copy following code and put it at the place of your HTML document.

    <link href='http://tmtk75.github.com/jumly/latest/jumly.min.css' rel="stylesheet"/>
    <script src='http://code.jquery.com/jquery-1.7.1.min.js'></script>
    <script src='http://jashkenas.github.com/coffee-script/extras/coffee-script.js'></script>
    <script src='http://tmtk75.github.com/jumly/latest/jumly.min.js'></script>
    <script type='text/jumly+sequence'>
    @found "You", ->
      @message "meet", "JUMLY"
    </script>

[Here is same one](/min-working.html), minimal working example.


## Features

- Easily embed some of UML diagrams with HTML5/CSS3.
- Rendered diagrams are composed in HTMLElement,
  which means all known ways for HTML/CSS are available.
- DSL based on coffeescript.
- Works on just client side.


## Links

- Website: <http://jumly.heroku.com>
- Blog: <http://tmtk75.github.com>


## License
**NOTE: License will be changed in the future.**

Now I'm contemplating which license I should choose.

Tentatively CC3.0.

<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-nd/3.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">jumly</span> by <span xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">Tomotaka Sakuma</span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/3.0/">Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License</a>.

Tomotaka Sakuma 2011-2012 copyright(c), all rights reserved.


## Changelog

### 0.1.2

### 0.1.1
- Implement JUMLY root namespace.
- Implement JUMLY.DiagramBuilder class, and its sub-classes.
- Enhance way to refer in JUMLY DSL.
- Improve website. Especially, TryJUMLY page.

### 0.1.0 <small>Initial release.</small>
- Enable to render sequence diagram.
- Able to try prototype of use-case diagram.
- Able to try prototype of class diagram.
