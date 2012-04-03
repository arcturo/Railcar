#
#  RCRubyInstaller.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/31/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCRubyManager
  attr_accessor :delegate

  def rbenvPath
    File.join(NSBundle.mainBundle.bundlePath, "homebrew", "Cellar", "rbenv", RBENV_VERSION, "bin", "rbenv")
  end

  def buildPath
    File.join(NSBundle.mainBundle.bundlePath, "homebrew", "Cellar", "ruby-build-fork", "03292012", "bin", "ruby-build")
  end

  def versionPath(version = nil)
    File.join(NSBundle.mainBundle.bundlePath, "rbenv", "versions", (version || DEFAULT_RUBY_VERSION))
  end

  def rbenvRoot
    File.join(NSBundle.mainBundle.bundlePath, "rbenv")
  end

  def brewPath
    File.join(NSBundle.mainBundle.bundlePath, "homebrew", "bin")
  end

  def install(version = nil)
    `CC='/usr/bin/gcc' #{buildPath} #{version || DEFAULT_RUBY_VERSION} #{versionPath(version)}`
    
    if ($?.exitstatus == 0)
      writeShellInitializer(version)
      delegate.newVersionInstalled(version || DEFAULT_RUBY_VERSION) if delegate
      return true
    else
      delegate.rubyInstallError if delegate
      return false
    end
  end

  def writeShellInitializer(version = nil)
    configuration = "export RBENV_ROOT=#{rbenvRoot}
    export PATH=#{rbenvPath}:#{brewPath}:$PATH
    eval \"$(rbenv init -)\"
    export RBENV_VERSION=\"#{version || DEFAULT_RUBY_VERSION}\"
    cd ~
    clear
    echo 'Railcar Shell -- Setup for #{version || DEFAULT_RUBY_VERSION}'"
    
    Dir.mkdir(File.join(NSBundle.mainBundle.bundlePath, "initializers")) rescue nil # don't care if it exists already
    File.open(File.join(NSBundle.mainBundle.bundlePath, "initializers", "rbenv_init_#{version || DEFAULT_RUBY_VERSION}.sh"), "w") do |f|
      f.write(configuration)
    end
  end

  def refreshInstalledVersions
    @installedVersions = nil
    installedVersions
  end

  def installedVersions
    @installedVersions ||= Dir.entries(File.join(NSBundle.mainBundle.bundlePath, "rbenv", "versions")) - [".", ".."]
  end

  def installed?(version)
    installedVersions.include?(version)
  end
end
