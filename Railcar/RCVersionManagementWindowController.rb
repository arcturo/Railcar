#
#  RCVersionManagementWindowController.rb
#  Railcar
#
#  Created by Jeremy McAnally on 4/2/12.
#  Copyright 2012 Arcturo. All rights reserved.
#


class RCVersionManagementWindowController < NSWindowController
  attr_accessor :mriButton, :jrubyButton, :rbxButton, :maglevButton, :oldMriButton
  attr_accessor :spinner, :progressLabel

  def windowDidLoad
    super
    @rubyManager = RCRubyManager.new
    @rubyManager.delegate = self

    @versions = {
      "1.9.3-p125" => "MRI 1.9.3",
      "jruby-1.6.7" => "JRuby 1.6.7",
      "rbx-1.2.4" => "Rubinius 1.2.4",
      "maglev-1.0.0" => "MagLev",
      "1.8.7-p358" => "MRI 1.8.7"
    }

    # TODO: Again, custom views instead of this?  Not sure it would be worth the
    # effort here...
    @buttons = [mriButton, jrubyButton, rbxButton, maglevButton, oldMriButton]
    updateInstallButtons
  end

  def installNewVersion(sender)
    spinner.startAnimation(self)

    version_name = @versions.values[sender.tag.to_i]
    version = @versions.keys[sender.tag.to_i]

    progressLabel.setStringValue("Installing #{version_name}...")

    Thread.new do
      @rubyManager.install(version)      
    end

    @buttons.each {|b| b.setEnabled(false)}
  end

  def updateInstallButtons
    version_aliases = @versions.keys
    @buttons.each_with_index do |button, index|
      if @rubyManager.installed?(version_aliases[index])
        button.setTitle("Installed")
        button.setEnabled(false)
      else
        button.setTitle("Install #{@versions[version_aliases[index]]}")
        button.setEnabled(true)
      end
    end
  end

  def newVersionInstalled(version)
    spinner.stopAnimation(self)
    progressLabel.setStringValue("")

    refreshInstalledVersions
  end

  def refreshInstalledVersions
    @rubyManager.refreshInstalledVersions
    updateInstallButtons
  end

  def windowDidBecomeKey(notification)
    refreshInstalledVersions
  end
end