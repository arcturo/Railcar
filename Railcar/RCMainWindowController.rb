#
#  RCMainWindowController.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/30/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCMainWindowController < NSWindowController 
  attr_accessor :packages_button
  
  def windowDidLoad
    super
  end

  def managePackages(sender)
    @packageWindowController ||= RCPackageManagementWindowController.alloc.initWithWindowNibName("PackageManagementWindow")
    @packageWindowController.window.makeKeyAndOrderFront(self)
  end
  
  def manageVersions(sender)
    @versionsWindowController ||= RCVersionManagementWindowController.alloc.initWithWindowNibName("RubyManagementWindow")
    @versionsWindowController.window.makeKeyAndOrderFront(self)
  end
end