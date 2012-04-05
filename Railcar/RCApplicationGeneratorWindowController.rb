#
#  RCApplicationGeneratorWindowController.rb
#  Railcar
#
#  Created by Jeremy McAnally on 4/4/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCApplicationGeneratorWindowController < NSWindowController
  attr_accessor :versionSelector, :portField, :pathField, :nameField, :databaseSelector, :versionControlSelector
  attr_accessor :testingSelector, :gitFileCheckbox, :initializeCheckbox, :generateButton, :skipActiveRecordCheckbox
  attr_accessor :skipAssetPipelineCheckbox, :skipBundlerCheckbox, :launchCheckbox, :spinner

  def windowDidLoad
    super
  end

  def awakeFromNib
    refreshVersions
    portField.setStringValue((NSUserDefaults.standardUserDefaults['railcar.linkedApplications'].length + 3001).to_s)
    pathField.setStringValue(NSHomeDirectory())

    refreshDatabases
    versionControlSelector.removeAllItems
    versionControlSelector.addItemsWithTitles(["Git", "Mercurial", "Subversion"])
    testingSelector.removeAllItems
    testingSelector.addItemsWithTitles(["MiniTest/Test::Unit", "RSpec", "RSpec + Cucumber"])
  end

  def refreshDatabases
    brew = RCBrewManager.new

    databases = ["Sqlite", "MySQL", "PostgreSQL"].map do |db|
      # TODO: This is sort of icky.  Clean it up!
      info = RCAvailablePackages.inCategory("db").select {|package| package[:name] == db}.first || {:brewName => "sqlite"}

      brew.installed?(info[:brewName]) ? db : "#{db} (not installed with Railcar)"
    end

    databaseSelector.removeAllItems
    databaseSelector.addItemsWithTitles(databases)
  end

  def refreshVersions
    versionSelector.removeAllItems
    versionSelector.addItemsWithTitles(RCRubyManager.new.installedVersions)

    versionSelector.selectItemWithTitle(DEFAULT_RUBY_VERSION)
  end

  def toggleVersionControl(sender)
    gitFileCheckbox.setEnabled(sender.state == 1)
    versionControlSelector.setEnabled(sender.state == 1)
    initializeCheckbox.setEnabled(sender.state == 1)
  end

  def pickVersionControl(sender)
    if sender.selectedItem.title == "Git"
      gitFileCheckbox.setEnabled(true)
    else
      gitFileCheckbox.setEnabled(false)
      gitFileCheckbox.setState(1)
    end
  end

  def browsePath(sender)
    dialog = NSOpenPanel.openPanel

    dialog.setCanChooseFiles(false)
    dialog.setCanChooseDirectories(true)

    if (dialog.runModalForDirectory(nil, file:nil) == NSOKButton)
      pathField.setStringValue(dialog.filenames.first)
    end
  end

  def controlTextDidChange(notification)
    generateButton.setEnabled(!(pathField.stringValue.empty? || portField.stringValue.empty? || nameField.stringValue.empty?))
  end

  def generateApplication(sender)
    generator = RCApplicationGenerator.new(self)
    generator.delegate = self
    
    toggleControlsEnabled(false)
    generateButton.setTitle("Generating")
    spinner.startAnimation(self)

    Thread.new do
      generator.generate
    end
  end

  def toggleControlsEnabled(value)
    [versionSelector, portField, pathField, nameField, databaseSelector, versionControlSelector,
     testingSelector, gitFileCheckbox, initializeCheckbox, generateButton, skipActiveRecordCheckbox,
     skipAssetPipelineCheckbox, skipBundlerCheckbox, launchCheckbox].each {|control| control.setEnabled(value)}
  end

  def generationComplete(path)
    spinner.stopAnimation(self)
    manager = RCApplicationManager.alloc.init

    manager.add(path, {
      :rubyVersion => versionSelector.selectedItem.title,
      :port => portField.stringValue
    })

    window.close
  end

  def generationError
    spinner.stopAnimation(self)
    generateButton.setTitle("Generate")
    toggleControlsEnabled(true)
  
    alert = NSAlert.alertWithMessageText("Generator error!", defaultButton: "OK", alternateButton: nil, otherButton: nil, informativeTextWithFormat: "Looks like there was an error when generating your application.  Make sure the path you provided is valid!")
    alert.setIcon(NSImage.imageNamed("error.png"))
    alert.beginSheetModalForWindow(window, modalDelegate: self, didEndSelector: nil, contextInfo: nil)
  end
end
