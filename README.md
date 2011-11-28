

  README
=======================================================================
  jumly is a jQuery plug-in to compose UML diagrams which are styled with Pure HTML5/CSS3.

  What are features?

  - Pure HTML5/CSS3
    + All diagrams is based on DOM. It means you can edit anything after rendering,
      and apply your style sheet to customize looks.
  
  - Works on client side.
    + Never connect to a server. You can use most of all on offline.
    + You just load two files, .js/.css files, in your HTML file.
  
  - Typeless as possible, but rich looks
    + You can get rich looks diagrams with a simple DSL baseed on coffeescript,
      and it\'s easy to compose some complex compositions.
  
  - Everything is text
    + Copy & Paste, preparing template, and you can use a lot of know-how about plain text.
    + Certainly, easy versioning and comparing with svn, git, and hg.
    + If you are cool software engineer, you'll understand this is wonderful :)
  


  Do you have the time you want to write a simple sequence diagram to express a something procedure?
  Then, what application do you use for it?  PowerPoint? Visio? or Hand-writing?
  There are many applications to draw sequence diagram, but they often are not suitable to your use,
  and they are ususally too big and complicated for your purpose.


  jumly provides a way to render easily UML diagrams on your browser.



  Introduction
-----------------------------------------------------------------------

  ![webapp](doc/images/fig-1.png "webapp")

  To get the above, you can write the below apart from HTML tags and so on.

    $.uml(".sequence-diagram")
    .found "HTTP Client", ->
        @message "request", "HTTP Server"
    .compose $ "body"

  The first and last line are a typical code to show diagram.
  If you removes the first and last ones, you write just two lines to render the diagram.


  ![webapp](doc/images/fig-2.png "webapp")

  Further like the above, to get next `POST` message, you can only continue `@message` like this:

    .found "HTTP Client", ->
        @message "request", "HTTP Server", ->
            @message "POST", "Application Server"
    .compose $ "body"

  Finally, I\'ll show you a sequence diagram to express behavior of a web application.

  ![webapp](doc/images/fig-3.png "webapp")

    $.uml(".sequence-diagram")
    .found "HTTP Client", ->
        @message "request", "HTTP Server", ->
            @message "POST", "Application Server", ->
                @create "HTTP Session"
                @message "persist the session", "Database"
                @reply "session key on cookie", "HTTP Client"
    .compose $ "body"


  These examples are images, but actually you can get them as **styled HTML elements** with jumly.
  Check out [this example][thissample], and try to copy, to drag it, see the source code, or view
  the tree of elements with a DeveloperTool of your browser.
  You will understand it consists of some usual HTML elements soon.

  [thissample]: doc/example/getstarted.html "Web application sequence"

  What is this meaning? You can use a lot of technologies and techniques for HTML document
  like stylesheet, JavaScript, AJAX, jQuery... there are many ones.



  Get started
-----------------------------------------------------------------------

  Insert four tags in order to load into the head of your HTML file.

    <link rel="stylesheet" type="text/css" href="public/stylesheets/jumly-min.css"/>
    <script type="text/javascript" src="vendor/jquery-1.6.2.min.js"></script>
    <script type="text/javascript" src="vendor/coffee-script.min-1.1.1.js"></script>
    <script type="text/javascript" src="public/javascripts/jumly-min.js"></script>


  And put a script tag like this.

    <script type='text/coffeescript'>
    $.uml(".sequence-diagram")
    .found "A", ->
      @message "a", "B"
      .compose $ "body"
    </script>

  That's all.


  Here is an available example.

    <html><head>
      <link rel="stylesheet" type="text/css" href="public/stylesheets/jumly-min.css"/>
      <script type="text/javascript" src="vendor/jquery-1.6.2.min.js"></script>
      <script type="text/javascript" src="vendor/coffee-script.min-1.1.1.js"></script>
      <script type="text/javascript" src="public/javascripts/jumly-min.js"></script>
      <script type='text/coffeescript'>
      $.uml(".sequence-diagram")
      .found "A", ->
        @message "a", "B"
        .compose $ "body"
      </script>
    </head><body></body><html>


  Showcase
-----------------------------------------------------------------------

  Here is [showcase](/example)


  Examples
-----------------------------------------------------------------------

  - sequence diagram
    + [Get started](/doc/example/getstarted.html)
    + [HTTP Request](/doc/example/http-request.html)
    + [On the fly](/doc/example/on-the-fly.html)
    + [Order](/doc/example/order.html)
    + [OSGi](/doc/example/osgi.html)
    + [Register](/doc/example/register.html)
    + [Restaurant](/doc/example/restaurant.html)


  Limitation
-----------------------------------------------------------------------
  - Support Webkit-base browser and Opera only. IE & Firefox are not supported now.


  License
-----------------------------------------------------------------------

  <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-nd/3.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">jumly</span> by <span xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">Tomotaka Sakuma</span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/3.0/">Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License</a>.


  Known Issues
----------------------------------------------------------------------
  - Doesn't work if display is not .relative or float is left for .diagram.
    Can't retrieve .object width including padding/margin, and can't align them.

  - .ref doesn't work in left-floating element.


  Misc
----------------------------------------------------------------------
### Kind of diagrams
  + Sequence
  + Use-case
  + Component
  + Deployment
  + Robustness
  + Class
  + Statechart
  + Collaboration
  + Object
  + Activity


### Test for Markdown notation in kramdown
  Can I use definition list?

  coffee-script
  : The most interesting programming language I like.

  javascript
  : is a popular language to run on client side.


  And also use footnote?

  This is a pen.[^1]

  [^1]: I can hope this...



  README
========================================================================

  + heroku <http://falling-light-422.heroku.com/>
  + GAE <http://limecrow.appspot.com/>

  Launching locally and Deployment
------------------------------------------------------------------------

### Rack on [heroku](git@heroku.com:falling-light-422.git) http://www.heroku.com/

  To launch

    $ rackup -p 8080

  To deploy

    $ git push heroku master
    $ heroku open

### GAE with python

  To launch

    $ <PY_APPENGINE_HOME>/dev_appserver.py .

  To deploy

    $ <PY_APPENGINE_HOME>/appcfg.py update .

### GAE with Java

  Initially, you have to build

    $ mvn install

  To launch

    $ <JAVA_APPENGINE_HOME>/bin/dev_appserver.sh target/jumlyweb-<VERSION>

  To deploy

    $ <JAVA_APPENGINE_HOME>/bin/appcfg.sh update target/jumlyweb-<VERSION>

