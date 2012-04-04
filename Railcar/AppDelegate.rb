#
#  AppDelegate.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/30/12.
#  Copyright 2012 Arcturo. All rights reserved.
#
require 'Configuration'
framework 'Cocoa'

class AppDelegate
  attr_accessor :window
  
  def applicationDidFinishLaunching(a_notification)
    installer = RCBootstrapper.new
    
    if installer.needsInstall?
      @bootstrapWindowController = RCSetupWindowController.alloc.initWithWindowNibName("SetupWindow")
      installer.delegate = @bootstrapWindowController
      @bootstrapWindowController.installer = installer
       
      bootstrapWindow = @bootstrapWindowController.window
      NSApp.runModalForWindow(bootstrapWindow)
      NSApp.endSheet(bootstrapWindow)
      bootstrapWindow.orderOut(self)
    end

    # Did they somehow get around it?
    if installer.needsInstall?
      exit
    else
      @mainWindowController = RCMainWindowController.alloc.initWithWindowNibName("MainWindow")      
      @mainWindowController.window.makeKeyAndOrderFront(self)
    end
  end
  
  def applicationShouldTerminate(sender)
    if @mainWindowController
      @mainWindowController.stopAllApplications

      NSTerminateNow
    end
  end
end

