#
#  ApplicationListDataSource.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/30/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCApplicationListDataSource
  attr_accessor :table, :window

  def initialize
    @applicationManager = RCApplicationManager.new
  end

  def numberOfRowsInTableView(tableView)
    @applicationManager.applications.keys.length
  end

  def tableView(view, objectValueForTableColumn:column, row:index)
    "  " + @applicationManager.applications[@applicationManager.applications.keys[index]][:name].to_s
  end

  def selectedApplication
    key = @applicationManager.applications.keys[table.selectedRow]
    [key, @applicationManager.applications[key]]
  end

  # Drag and drop operations
  def tableView(aView, validateDrop:info, proposedRow:row, proposedDropOperation:op)
    NSDragOperationEvery
  end

  def tableView(aView, acceptDrop:info, row:row, dropOperation:op)
    path = info.draggingPasteboard.propertyListForType("NSFilenamesPboardType").first
    
    if @applicationManager.add(path)
      updateApplicationList
      return true
    else
      alert = NSAlert.alertWithMessageText("Invalid Rails application!", defaultButton: "OK", alternateButton: nil, otherButton: nil, informativeTextWithFormat: "That doesn't appear to be a Rails application; please drop a Rails application on to the list to add it.")
      alert.setIcon(NSImage.imageNamed("error.png"))
      alert.beginSheetModalForWindow(window, modalDelegate: self, didEndSelector: nil, contextInfo: nil)

      return false
    end
  end

  def updateApplicationList
    table.reloadData
  end

  def awakeFromNib
    table.registerForDraggedTypes([NSFilenamesPboardType])
  end
end