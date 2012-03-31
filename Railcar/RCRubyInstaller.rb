#
#  RCRubyInstaller.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/31/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCRubyInstaller
  def buildPath
    File.join(NSBundle.mainBundle.bundlePath, "homebrew", "Cellar", "ruby-build-fork", "03292012", "bin", "ruby-build")
  end

  def versionPath(version = nil)
    File.join(NSBundle.mainBundle.bundlePath, "rbenv", "versions", (version || DEFAULT_RUBY_VERSION))
  end

  def install(version = nil)
    `CC='/usr/bin/gcc' #{buildPath} #{version || DEFAULT_RUBY_VERSION} #{versionPath(version)}`
    
    ($?.exitstatus == 0)
  end
end
