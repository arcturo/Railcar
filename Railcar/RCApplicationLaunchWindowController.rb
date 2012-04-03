#
#  ApplicationLaunchWindowController.rb
#  Railcar
#
#  Created by Jeremy McAnally on 4/2/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCApplicationLaunchWindowController < NSWindowController
  attr_accessor :controlButton, :versionSelector, :environmentSelector, :portField, :nameLabel, :pathLabel
  attr_accessor :appLink, :appLinkLabel, :databaseLabel, :versionControlLabel, :versionControlStatusLabel

  def windowDidLoad
    super
  end

  def awakeFromNib
    nameLabel.setStringValue(@data['name'])
    pathLabel.setStringValue(@data['path'])

    portField.setStringValue(@data['port'] || "3000")

    refreshVersions
    refreshEnvironments

    databaseLabel.setStringValue(@app.databaseInfo)
    refreshVersionControl
  end

  def initWithData(key, data)
    initWithWindowNibName("ApplicationLaunchWindow")

    @data = data
    @app = RCApplicationInstance.new(key, data)

    self
  end

  def controlClick(sender)
    @app.launched? ? stopApplication : launchApplication
  end

  def getConsole(sender)    
    command = "tell application \"Terminal\" to do script \"source #{@app.initializerPath}\""
    
    scriptRunner = NSAppleScript.alloc.initWithSource(command)
    scriptRunner.executeAndReturnError(nil)
  end

  def stopApplication
    controlButton.setEnabled(false)
    
    @app.stop

    appLink.setHidden(true)
    appLinkLabel.setHidden(true)

    controlButton.setTitle("Launch")
    controlButton.setEnabled(true)
  end

  def launchApplication
    controlButton.setEnabled(false)

    if @app.launch
      appLink.setStringValue("http://localhost:#{@app.port}/")
      appLink.setHidden(false)
      appLinkLabel.setHidden(false)

      controlButton.setTitle("Stop")
    else
      appLink.setHidden(true)
      appLinkLabel.setHidden(true)

      alert = NSAlert.alertWithMessageText("Application launch failed!", defaultButton: "OK", alternateButton: nil, otherButton: nil, informativeTextWithFormat: "Your application failed to launch!  You may try launching it from the console with 'rails s' to see what the error is.")
      alert.setIcon(NSImage.imageNamed("error.png"))
      alert.beginSheetModalForWindow(window, modalDelegate: self, didEndSelector: nil, contextInfo: nil)
    end
    
    controlButton.setEnabled(true)
  end

  def refreshVersions
    versionSelector.removeAllItems
    versionSelector.addItemsWithTitles(RCRubyManager.new.installedVersions)

    versionSelector.selectItemWithTitle(@data['rubyVersion'])
  end

  def refreshEnvironments    
    environmentSelector.removeAllItems
    environmentSelector.addItemsWithTitles(@app.environments)

    environmentSelector.selectItemWithTitle(@data['environment'])
  end

  def refreshVersionControl
    info = @app.versionControlStatus
    
    versionControlLabel.setStringValue(info[:name])
    versionControlStatusLabel.setStringValue(info[:status])
  end
end