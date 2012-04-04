#
#  RCMainWindowController.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/30/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCMainWindowController < NSWindowController 
  attr_accessor :packagesButton, :applicationsTable, :dataSource, :appControllers
  
  def windowDidLoad
    super
  end

  def awakeFromNib
    applicationsTable.setTarget(self)
    applicationsTable.setDoubleAction("showLaunchWindow")
  end

  # TODO: DRY this up.
  def launchApplication(sender)
    key, app = dataSource.selectedApplication

    @appControllers ||= {}
    @appControllers[app] ||= RCApplicationLaunchWindowController.alloc.initWithData(key, app)
    @appControllers[app].launchApplication
    @appControllers[app].window.makeKeyAndOrderFront(self)
  end

  def showLaunchWindow
    key, app = dataSource.selectedApplication

    @appControllers ||= {}
    @appControllers[app] ||= RCApplicationLaunchWindowController.alloc.initWithData(key, app)
    @appControllers[app].window.makeKeyAndOrderFront(self)
  end

  def stopAllApplications
    if appControllers && !appControllers.empty?
      appControllers.values.each {|controller| controller.stopApplication }
    end
  end

  def managePackages(sender)
    @packageWindowController ||= RCPackageManagementWindowController.alloc.initWithWindowNibName("PackageManagementWindow")
    @packageWindowController.window.makeKeyAndOrderFront(self)
  end
  
  def manageVersions(sender)
    @versionsWindowController ||= RCVersionManagementWindowController.alloc.initWithWindowNibName("RubyManagementWindow")
    @versionsWindowController.window.makeKeyAndOrderFront(self)
  end

  def generateApplication(sender)
    controller = RCApplicationGeneratorWindowController.alloc.initWithWindowNibName("ApplicationGeneratorWindow")
    controller.window.makeKeyAndOrderFront(self)
  end    
end