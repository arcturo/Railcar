require 'Configuration'

class RCInstaller
  attr_accessor :delegate
  
  def installDependencies
    if needsInstall?
      begin
        checkForCompiler
        installBrew
        installRbenv
        installRuby
        installDefaultGems
        writeShellInitializer
      rescue StandardError => e
        delegate.errorOccurred(e.message)
      end
    else
      delegate.noInstallNeeded
    end
  end

  def checkForCompiler
    if File.exist?("/usr/bin/gcc")
      delegate.compilerExists
    else
      raise "Compiler not found!  Please install XCode or GCC."
    end
  end
  
  def installBrew
    pathToScript = NSBundle.mainBundle.pathForResource('install_brew', ofType:"sh")
    
    `/bin/sh #{pathToScript} #{BREW_DOWNLOAD_URL} #{NSBundle.mainBundle.bundlePath}`
    raise "Brew install failed!" if ($?.exitstatus > 0)

    brewPath = File.join(NSBundle.mainBundle.bundlePath, "homebrew", "bin", "brew")
    
    `#{brewPath} tap jm/env`
    ($?.exitstatus > 0) ? raise("Brew tap failed!") : delegate.brewInstalled
  end
  
  def installRbenv
    return true if (File.exist?(File.join(NSBundle.mainBundle.bundlePath, "homebrew", "Cellar", "rbenv", "0.3.0", "bin", "rbenv")))

    brewPath = File.join(NSBundle.mainBundle.bundlePath, "homebrew", "bin", "brew")

    `#{brewPath} install rbenv`
    raise "RbEnv install failed!" if ($?.exitstatus > 0)

    `#{brewPath} install ruby-build-fork`
    ($?.exitstatus > 0) ? raise("ruby-build install failed!") : delegate.rbenvInstalled
  end

  def installRuby
    return true if (File.exist?(File.join(NSBundle.mainBundle.bundlePath, "homebrew", "Cellar", "rbenv", "0.3.0", "versions", DEFAULT_RUBY_VERSION, "bin", "ruby")))
    
    buildPath = File.join(NSBundle.mainBundle.bundlePath, "homebrew", "Cellar", "ruby-build-fork", "03292012", "bin", "ruby-build")
    versionPath = File.join(NSBundle.mainBundle.bundlePath, "homebrew", "Cellar", "rbenv", "0.3.0", "versions", DEFAULT_RUBY_VERSION)
    
    `CC='/usr/bin/gcc' #{buildPath} #{DEFAULT_RUBY_VERSION} #{versionPath}`
        
    ($?.exitstatus > 0) ? raise("Ruby install failed!") : delegate.rubyInstalled
  end

  def installDefaultGems
    rbenvPath = File.join(NSBundle.mainBundle.bundlePath, "homebrew", "Cellar", "rbenv", "0.3.0")
    pathToScript = NSBundle.mainBundle.pathForResource('install_gems', ofType:"sh")
    `/bin/sh #{pathToScript} #{rbenvPath} #{DEFAULT_GEMS}`
  
    ($?.exitstatus > 0) ? raise("Gems installation failed!") : delegate.gemsInstalled
  end

  def writeShellInitializer
    rbenvPath = File.join(NSBundle.mainBundle.bundlePath, "homebrew", "Cellar", "rbenv", "0.3.0")
        
    configuration = "export RBENV_ROOT=#{rbenvPath}
    export PATH=#{File.join(rbenvPath, 'bin')}:$PATH
    eval \"$(rbenv init -)\"
    export RBENV_VERSION=\"#{DEFAULT_RUBY_VERSION}\"
    cd ~
    clear
    echo 'Shell setup for Rails -- go nuts!'"
    
    File.open(File.join(NSBundle.mainBundle.bundlePath, "homebrew", "rbenv_init.sh"), "w") do |f|
      f.write(configuration)
    end
  end

  def needsInstall?
    !(File.exist?(File.join(NSBundle.mainBundle.bundlePath, "homebrew", "rbenv_init.sh")))
  end
end