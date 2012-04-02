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
    @windowController ||= RCPackageManagementWindowController.alloc.initWithWindowNibName("PackageManagementWindow")
    @windowController.window.makeKeyAndOrderFront(self)
  end
end