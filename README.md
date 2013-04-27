# README

JUMLY is a JavaScript library.  
Using JUMLY, you can easily embed UML diagram on your HTML document.  
All you need are just two things you use everyday.

- Text editor you get used to use.
- A modern browser like WebKit-base brwoser and Opera.  
  (working for Firefox now)

For more information, see <https://jumly.herokuapp.com/>.  
The auther's blog is <http://tmtk75.github.com>.


# Getting Started
Copy following code,
paste it at the place of your HTML document,
and open the document.

    <link href='https://jumly.herokuapp.com/release/jumly.min.css' rel="stylesheet"/>
    <script src='http://code.jquery.com/jquery-2.0.0.min.js'></script>
    <script src='http://jashkenas.github.com/coffee-script/extras/coffee-script.js'></script>
    <script src='https://jumly.herokuapp.com/release/jumly.min.js'></script>
    <script type='text/jumly+sequence'>
    @found "You", ->
      @message "meet", "JUMLY"
    </script>

[Here](http://jumly.herokuapp.com/examples/simple.html) is a minimal sample.


# How to build
Requiring [node.js](http://nodejs.org/) v0.8.9 or upper.

## node.js installation
[nvm](https://github.com/creationix/nvm) is good to get it.

    $ git clone git://github.com/creationix/nvm.git ~/.nvm
    $ . ~/.nvm/nvm.sh
    $ nvm install 0.8.16
    
## Build jumly

In order to build jumly.js, jumly.css and minified ones, it's shortly steps.

    $ git clone https://github.com/tmtk75/jumly.git
    $ cd jumly
    $ npm install
    $ . .env
    $ grunt

`./build` directory is created and it contains them.


# How to develop
Written in CoffeeScript and stylus. They are in `./lib` directory.
`./lib/js/jumly.coffee` organizes other \*.coffee files in order.

On a webapp, which is described at [next](#how-to-launch-the-webapp),
you can use them without build.
Editing \*.coffee and \*.styl, reload a page of webapp, and your change will make effect.


# How to launch the webapp
You can launch the webapp using [express](http://expressjs.com/).

    $ . .env
    $ git submodule update --init
    $ ./app.coffee
    
Please access to [localhost:3000](http://localhost:3000) thru your browser.


# How to run specs
Compile spec files, and open `./spec/index.html` with your browser.

To compile them,

    $ . .env
    $ grunt compile
    $ open spec/index.html
    
[jasmine](http://pivotal.github.com/jasmine/) is used for writing specs.


# License
JUMLY v0.1.3b is under [MIT License](http://opensource.org/licenses/MIT).

JUMLY v0.1.3b, 2010-2013 copyright(c), all rights reserved Tomotaka Sakuma.


# History
- 0.1.3b, Apr 27, 2013
  - API JUMLY.scan (beta)
- 0.1.3a, Mar 29, 2013
  - Robustness diagram prototyping
  - Fixed pollution of jQuery namespace with some funcitons
- Use GRUNT for bulid, Mar 10, 2013
- 0.1.2b, Jan 9, 2013
  - @fragment directive
- 0.1.2a, Dec 31, 2012
  - Fixed https://github.com/tmtk75/jumly/issues/4
- Try JUMLY, Dec 29, 2012
  - interactive demo for sequence diagram
- 0.1.2, Dec 29, 2012
  - change CSS class name for .participant, which was .object
- Reference Manual r1 published Dec 10, 2012
- 0.1.1 Nov 29, 2012
  - support @note directive
  - adjust margins and spaces in stylesheet
- 0.1.0 Nov 23, 2012 -- initial release
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
- GRUNT <http://gruntjs.com/>
