require 'RCBrewManager'
require 'RCRubyManager'

class RCBootstrapper
  attr_accessor :delegate
  
  def installDependencies
    puts("starting")
    if needsInstall?
      begin
        checkForCompiler
        
        installBrew if needsBrew?
        installRbenv if needsRbEnv?
        installRuby if needsRuby?

        installDefaultGems
      rescue StandardError => e
        delegate.errorOccurred(e.message)
      end
    else
      delegate.noInstallNeeded
    end
  end

  def needsBrew?
    !(File.exist?(File.join(NSBundle.mainBundle.bundlePath, "homebrew", "bin", "brew")))
  end

  def needsRbEnv?
    !(File.exist?(File.join(NSBundle.mainBundle.bundlePath, "homebrew", "Cellar", "rbenv", RBENV_VERSION, "bin", "rbenv")))
  end

  def needsRuby?
    !(File.exist?(File.join(NSBundle.mainBundle.bundlePath, "rbenv", "versions", DEFAULT_RUBY_VERSION, "bin", "ruby")))
  end

  def checkForCompiler
    puts("checking for compiler")
    if File.exist?("/usr/bin/gcc")
      delegate.compilerExists
    else
      raise "Compiler not found!  Please install XCode or GCC."
    end
  end
  
  def installBrew
    puts("installing brew")
    pathToScript = NSBundle.mainBundle.pathForResource('install_brew', ofType:"sh")
    
    `/bin/sh #{pathToScript} #{BREW_DOWNLOAD_URL} #{NSBundle.mainBundle.bundlePath}`
    raise "Brew install failed!" if ($?.exitstatus > 0)

    brewPath = File.join(NSBundle.mainBundle.bundlePath, "homebrew", "bin", "brew")
    
    `#{brewPath} tap jm/env`
    ($?.exitstatus > 0) ? raise("Brew tap failed!") : delegate.brewInstalled
  end
  
  def installRbenv
    puts("installing rbenv")
    brewInstaller = RCBrewManager.new

    raise "RbEnv install failed!" unless brewInstaller.install("rbenv")

    brewInstaller.install("ruby-build-fork") ? delegate.rbenvInstalled : raise("ruby-build install failed!")
  end

  def installRuby(version = nil)  
    puts("installing ruby")
    
    rubyInstaller = RCRubyManager.new
    rubyInstaller.install(version || DEFAULT_RUBY_VERSION) ? delegate.rubyInstalled : raise("Ruby install failed!")
  end

  def installDefaultGems(version = nil)
    puts("installing gems")
    pathToInitializer = File.join(NSBundle.mainBundle.bundlePath, "initializers", "rbenv_init_#{version || DEFAULT_RUBY_VERSION}.sh")
    
    `source #{pathToInitializer} && rbenv exec gem install --no-rdoc --no-ri #{DEFAULT_GEMS}`
  
    ($?.exitstatus > 0) ? raise("Gems installation failed!") : delegate.gemsInstalled
  end

  def needsInstall?
    Dir.glob(File.join(NSBundle.mainBundle.bundlePath, "initializers", "rbenv_init_*.sh")).empty?
  end
end