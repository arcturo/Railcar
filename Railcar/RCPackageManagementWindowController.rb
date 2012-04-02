#
#  Created by Jeremy McAnally on 3/30/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCPackageManagementWindowController < NSWindowController  
  attr_accessor :selectedPackage, :databaseDataSource, :languageDataSource, :libraryDataSource

  # TODO: Build a custom NSCell and put the install buttons on the row in the table
  # TOOD: We could probably wrap these into a custom view instead of all this junk...?
  attr_accessor :databaseInstallButton, :databaseProgressBar, :databaseProgressLabel, :databaseTable
  attr_accessor :languageInstallButton, :languageProgressBar, :languageProgressLabel, :languageTable
  attr_accessor :libraryInstallButton, :libraryProgressBar, :libraryProgressLabel, :libraryTable

  def windowDidLoad
    super

    @brew = RCBrewManager.new

    @buttons = {
    "db" => databaseInstallButton, 
    "language" => languageInstallButton, 
    "lib" => libraryInstallButton
    }

    @labels = [databaseProgressLabel, languageProgressLabel, libraryProgressLabel]
    @progressBars = [databaseProgressBar, languageProgressBar, libraryProgressBar]
    @tables = [databaseTable, languageTable, libraryTable]
    @sources = [databaseDataSource, languageDataSource, libraryDataSource]

    databaseInstallButton.setEnabled(false)
    languageInstallButton.setEnabled(false)
    libraryInstallButton.setEnabled(false)
  end

  def selectedPackageDidChange(category)    
    @buttons[category].setEnabled(!!selectedPackage)
  end

  def installSelectedPackage(sender)
    if selectedPackage      
      @progressBars.each {|b| b.startAnimation(self) }
      @labels.each {|l| l.setStringValue("Downloading and installing #{selectedPackage[:name]}, please wait...") }
      @buttons.values.each {|b| b.setEnabled(false)}

      @brew.delegate = self
      pkgName = selectedPackage[:brewName]
      Thread.new do
        @brew.install pkgName
      end

      @tables.each do |t| 
        t.deselectRow(t.selectedRow)
        t.setEnabled(false)
      end
    end
  end

  def packageInstalled(name)
    @progressBars.each {|b| b.stopAnimation(self) }
    @labels.each {|l| l.setStringValue("") }
    @buttons.values.each {|b| b.setEnabled(true)}

    @tables.each do |t| 
      t.setEnabled(true)
      t.reloadData
    end

    @sources.each(&:refresh)
  end

  def windowDidBecomeKey(notification)
    @sources.each(&:refresh)
    @tables.each(&:reloadData)
  end
end