# README

JUMLY is a JavaScript library.  
Using JUMLY, you can easily embed UML diagram on your HTML document.  
All you need are just one.

- Text editor you get used to use.
- A modern browser like WebKit-base brwoser and Opera.  
  (working for Firefox now)

For more information, see <https://jumly.herokuapp.com/>.  
The auther's blog is <http://tmtk75.github.com>.


## Getting Started
Copy following code,
paste it at the place of your HTML document,
and open the document.

    <link href='https://jumly.herokuapp.com/release/0.1.0/jumly.min.css' rel="stylesheet"/>
    <script src='http://code.jquery.com/jquery-1.7.1.min.js'></script>
    <script src='http://jashkenas.github.com/coffee-script/extras/coffee-script.js'></script>
    <script src='https://jumly.herokuapp.com/release/0.1.0/jumly.min.js'></script>
    <script type='text/jumly+sequence'>
    @found "You", ->
      @message "meet", "JUMLY"
    </script>

[Here](/examples/simple.html) is a minimal sample.


## License
JUMLY v0.1.0 is under [MIT License](http://opensource.org/licenses/MIT).

JUMLY v0.1.0, 2011-2012 copyright(c), all rights reserved Tomotaka Sakuma.


## Changelog
- 0.1.0 Initial release Nov 23, 2012
  - support sequence diagram

# Special Thanks
- jQuery <http://jquery.com/>
- CoffeeScript <http://coffeescript.org/>
- node.js <http://nodejs.org/>
- express <http://expressjs.com/>
- GitHub <https://github.com/>
- heroku <https://www.heroku.com/>
- jade <http://jade-lang.com/>
- Stylus <http://learnboost.github.com/stylus/>
- Markdown <https://daringfireball.net/projects/markdown/>
