#
#  RCBrewPackageInstaller.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/31/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCBrewPackageInstaller
  def brewPath
    # TODO: Later, we'll want to make this switch on whether we're using
    # system-wide brew or our local one
    File.join(NSBundle.mainBundle.bundlePath, "homebrew", "bin", "brew")
  end

  def install(name, extra_options='')
    `#{brewPath} install #{name} #{extra_options}`
    ($?.exitstatus == 0)
  end
end