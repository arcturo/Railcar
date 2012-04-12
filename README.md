# Railcar

Railcar is a fully isolated Rails development environment.  The application itself is developed in MacRuby using XCode and Interface Builder.  On first run, it will bootstrap itself with:

* An isolated, Railcar-owned installation of Homebrew
* RbEnv through Homebrew
* Ruby 1.9.3-p125 through RbEnv
* Sqlite through Homebrew
* Rails 3.2 (or whatever the latest release currently is)

These installations are isolated from your system installs, so if you're already using Homebrew, RVM, RbEnv, etc. then it won't mess with anything.  When you're done with Railcar, just toss the app bundle and all this stuff goes with it.

## Requirements

* Mac OS X 10.6+
* The latest version of MacRuby (currently 0.11)
* A C compiler (currently; we are working on changing that).  Preferred options:
  * XCode
  * Apple's command line tools downloadable from the Developer Center (GCC without XCode basically)
  * GCC installer package from here: [https://github.com/kennethreitz/osx-gcc-installer](https://github.com/kennethreitz/osx-gcc-installer)
  * GCC installed via Homebrew

## Usage

(Coming soon)

## Get Involved

How can you get involved?  There are a few ways:

* **Contribute code.**  There are a few `TODO` notes throughout the code, and you can find any bugs or issues filed here: [https://github.com/arcturo/Railcar/issues](https://github.com/arcturo/Railcar/issues) 
* **Contribute documentation.**  A nice wiki page with a quick tutorial about setting the app up and getting your first application generated and launched would be great.  Really anything!  Send pull requests for this README or add to the wiki here: [https://github.com/arcturo/Railcar/wiki](https://github.com/arcturo/Railcar/wiki)
* **Contribute funding.**  People have asked, so here it is.  If you'd like to contribute some funding, [click here](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=EUPXCZ5XKWX86).  If you hate PayPal, just e-mail me.  We'll figure something out.

## Contributors and Supporters

* Jeremy McAnally ([jm](http://github.com/jm)) - Initial proof of concept and app development
* [justinmcp](http://github.com/justinmcp) - [Fixed a minor bug with requires](https://github.com/arcturo/Railcar/pull/4)
