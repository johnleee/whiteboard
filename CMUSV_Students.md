CMU-SV Students
===============


## Getting Started for Students
1. install rails using railsinstaller.org        
1. rvm install ruby-1.9.2-p180
1. rvm --default use ruby-1.9.2-p180  ()
1. fork the project on github,
1. $ git clone http://github.com/URL/cmusv # to get the code
1. read {file:doc/Git_Directions.rdoc Git Directions}
1. $ cp config/database.default.yml config/database.yml -- see instructor for username and password
1. $ cp config/morning_glory.mfse.yml config/morning_glory.yml -- no need to configure
1. $ cp config/systems.default.yml config/systems.yml -- no need to configure
    1. create a config/amazon_s3.yml from (http://rails.sv.cmu.edu/pages/amazon_s3.yml)
1. create a config/google_apps.yml from (http://rails.sv.cmu.edu/pages/google_apps.yml)
1. set your environment variables
   1. (Mac OS X) install an Environment Preference pane (for your Systems Preference) using from http://www.rubicode.com/Downloads/RCEnvironment-1.4.X.dmg
   1. Note: This requires a restart. Source: http://www.rubicode.com/Software/RCEnvironment/
   1. Set these environment variables
      1. SEARCHIFY_API_URL=http://somethingrandom
      1. SEARCHIFY_INDEX=cmux_dev
      1. SEARCHIFY_STAFF_INDEX=cmu_staffx_dev
1. modify the db/seeds.rb and modify the example :your_name_here with yourself
    * Note: When you're prompted to login from the rails site with your email and password, you'll be redirected to google for authentication. After google approves of your credentials and sends you back to the rails site, the email used at time of login will be checked against the local db. This file populates the local db with your email/login data (see :your_name_here).
1. install postgres see http://rails.sv.cmu.edu/pages/postgres_rails
1. install a postgres database viewer (ie Navicat Lite http://www.navicat.com/en/download/download.html)
1. install imagemagick
   1. (Directions for a mac)
   1. install brew see http://mxcl.github.com/homebrew/  
   1. brew install imagemagick
1. bundle install      
   1. If this doesn't work see note below
1. bundle exec rake db:schema:load
1. bundle exec rake db:setup (to load the seeds.rb data)
1. bundle exec rake RAILS_ENV="test" db:schema:load
1. verify your configuration
   1. rails server thin  (Note: On 9/18/2011 WebBrick was not working with OmniAuth)
   1. bundle exec rake spec  (Verify that all the tests pass)
   1. run the server in debug mode in an IDE.
1. Tip: you can pretend to be any user in your development environment by modifying the current_user method of the application_controller
1. bundle exec rake doc:app (Generates API documentation for your models, controllers, helpers, and libraries.)
1. modify RubyMine to use thin instead of webbrick. On the tool bar, Run -> Edit Configurations. Instead of default server, pick thin.

### Installing Git
If you installed rails using railsinstaller.org, you should have git installed. 

* Mac users, Mountain Lion ships with 1.7.5.4 which is good enough.
* PC users,
   * Download "Full installer for official Git 1.7.6" here: http://code.google.com/p/msysgit/downloads/list (filename is Git-1.7.6-preview20110708.exe )
Run installer, accept license agreement, accept default installation directory, accept default shortcut options, keep all checkboxes checked
   * "Use Git Bash Only" radio button should be selected (per this article, avoids path conflicts)
   * "Use OpenSSH"
   * "Use Unix-style line endings"
   * (Note, these directions are from http://www.wiki.devchix.com)
* All users, from the terminal window or the command line, execute these commands but put in your own name and email address
   * git config --global user.name "Andrew Carnegie"
   * git config --global user.email andrew.carnegie@sv.cmu.edu
   * Create a user account on GitHub. Let the faculty know what your github user account is by modifying your profile page (e.g. http://rails.sv.cmu.edu/people/AndrewCarnegie)
   * Setup your ssh keys with GitHub http://help.github.com/key-setup-redirect       

#### Nokogiri issues

When i ran the bundle install, i got a strange error: 

Installing nokogiri (1.5.0) with native extensions 
Gem::Installer::ExtensionBuildError: ERROR: Failed to build gem native extension.

    /usr/local/rvm/rubies/ruby-1.9.2-p180/bin/ruby extconf.rb 
    checking for libxml/parser.h... yes
    checking for libxslt/xslt.h... yes
    checking for libexslt/exslt.h... yes
    checking for iconv_open() in iconv.h... no
    checking for iconv_open() in -liconv... no
 
    libiconv is missing.  please visit http://nokogiri.org/tutorials/installing_nokogiri.html for help with installing dependencies.

    Followed steps on  http://nokogiri.org/tutorials/installing_nokogiri.html, but had to make sure the version of nokogiri gem being installed was '1.5.0'. So instead of the last command in the instructions page, I had to run this:

    gem install nokogiri -v '1.5.0' -- --with-xml2-include=/usr/local/Cellar/libxml2/2.7.8/include/libxml2 --with-xml2-lib=/usr/local/Cellar/libxml2/2.7.8/lib --with-xslt-dir=/usr/local/Cellar/libxslt/1.1.26 --with-iconv-include=/usr/local/Cellar/libiconv/1.13.1/include --with-iconv-lib=/usr/local/Cellar/libiconv/1.13.1/lib

