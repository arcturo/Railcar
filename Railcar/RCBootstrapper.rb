require 'RCBrewManager'
require 'RCRubyManager'

class RCBootstrapper
  attr_accessor :delegate
  
  def installDependencies(fromSource = true)
    @fromSource = fromSource 
    
    puts("starting")
    if needsInstall?
      begin
        if buildFromSource?
          checkForCompiler
        else
          delegate.noCompilerNeeded
        end
        
        if needsBrew?
          installBrew
        else
          delegate.brewInstalled
        end

        if needsRbEnv?
          installRbenv 
        else
          delegate.rbenvInstalled
        end

        if needsRuby?
          installRuby
        else
          delegate.rubyInstalled
        end

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
    
    FileUtils.mkdir_p(File.join(NSBundle.mainBundle.bundlePath, "homebrew"))

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
    rubyInstaller.install((version || DEFAULT_RUBY_VERSION), buildFromSource?) ? delegate.rubyInstalled : raise("Ruby install failed!")
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
  
  def buildFromSource?
    @fromSource
  end
end