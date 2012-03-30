#
#  AppDelegate.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/30/12.
#  Copyright 2012 Arcturo. All rights reserved.
#
require 'Configuration'

class AppDelegate
  attr_accessor :window
  
  def applicationDidFinishLaunching(a_notification)
    installer = RCInstaller.new
      
    windowController = RCSetupWindowController.alloc.initWithWindowNibName("SetupWindow")
    installer.delegate = windowController;
    windowController.installer = installer;
      
    windowController.window.makeKeyAndOrderFront(self)
  end
end

