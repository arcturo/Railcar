#
#  RCBrewPackageInstaller.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/31/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCBrewManager
  attr_accessor :delegate

  def brewPath
    # TODO: Later, we'll want to make this switch on whether we're using
    # system-wide brew or our local one
    File.join(NSBundle.mainBundle.bundlePath, "homebrew", "bin", "brew")
  end

  def install(name, extra_options='')
    `#{brewPath} install #{name} #{extra_options}`
    
    delegate.packageInstalled(name) if ($?.exitstatus == 0) && delegate
    ($?.exitstatus == 0)
  end

  def refreshInstalledPackages
    @installed_packages = nil
    installed_packages
  end

  def installed_packages
    @installed_packages ||= `#{brewPath} list`.split("\n").map {|l| l.split("\t").map(&:strip)}.flatten
  end

  def installed?(name)
    installed_packages.include?(name)
  end
end