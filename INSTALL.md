  Prerequesties to build
-----------------------------------------------------------------------
  - coffee-script <http://jashkenas.github.com/coffee-script/>
    - node.js <http://nodejs.org/> <https://github.com/joyent/node>
    - npm <https://github.com/isaacs/npm>
  - sass <http://sass-lang.com/>
    - [Ruby 1.8.7 or higher][ruby]
    - rubygems
    - rake
    - kramdown
  - jasmine-story / jasmine
  - git
  - Mercurial

  [ruby]: http://www.ruby-lang.org/ "Ruby official site"


  Directory Layout
-----------------------------------------------------------------------
    .
    |-- README.md
    |-- Rakefile
    |-- public/
    |    |-- javascripts
    |    |-- stylesheets
    |    |-- example
    |    `-- spec
    |-- src/
    |    |-- coffee
    |    |-- scss
    |    `-- example
    |-- vendor
    |    |-- jasmine-story
    |    |-- jquery... and something


  Build
-----------------------------------------------------------------------

    $ rake dist

  That's all. You can get ./pkg/jumly-<version>.tar.gz


### Unbuntu-11.04 Desktop
    $ sudo apt-get install rubygems
    $ sudo gem install rake --no-rdoc --no-ri
    $ sudo gem install kramdown --no-rdoc --no-ri
    $ sudo gem install sass --no-rdoc --no-ri
    $ sudo apt-get install libhaml-ruby1.8

        $ sudo apt-get install nodejs
        $ sudo apt-get install coffeescript
        
        nodejs and coffeescript are in the repository, but too old.
        To install, see https://github.com/joyent/node/wiki/Installation

    $ sudo ln -s `which node` /usr/local/bin    
    $ sudo curl http://npmjs.org/install.sh | sudo sh
    $ sudo npm install -g coffee-script

