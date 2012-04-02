require 'RCBrewManager'

class RCPackageDataSource
  attr_accessor :table, :controller
  
  def category
    nil
  end
  
  def initialize
    @brew = RCBrewManager.new
    @packages = RCAvailablePackages.inCategory(self.category)
  end
  
  def numberOfRowsInTableView(tableView)
    @packages.length
  end

  def tableView(tableView, willDisplayCell:cell, forTableColumn:column, row:index)
    cell.setEnabled(!@brew.installed?(@packages[index][:brewName]))
  end

  def tableView(tableView, shouldSelectRow:row)
    !@brew.installed?(@packages[row][:brewName])
  end

  def tableViewSelectionDidChange(notification)
    if @table.selectedRow > -1
      controller.selectedPackage = @packages[@table.selectedRow]
      controller.selectedPackageDidChange(category)
    else
      controller.selectedPackage = nil
      controller.selectedPackageDidChange(category)
    end
  end

  def refresh
    @brew.refreshInstalledPackages
  end

  def tableView(tableView, objectValueForTableColumn:tableColumn, row:row)
    package = @packages[row].dup

    case tableColumn.identifier
      when 'image'
        NSImage.imageNamed package[:image] || "default.png"
      when 'description'
        paragraph = NSParagraphStyle.defaultParagraphStyle.mutableCopy
        paragraph.setParagraphSpacingBefore(30.0)
        paragraph.setMinimumLineHeight(30.0)

        attributed = ""

        if @brew.installed?(package[:brewName])
          package[:name] = package[:name] += " (Installed)"
        end

        attributed = NSMutableAttributedString.alloc.initWithString("#{package[:name]}\n#{package[:description]}")
        attributed.addAttribute(NSForegroundColorAttributeName, value:NSColor.grayColor, range:NSMakeRange(package[:name].length, package[:description].length + 1))

        attributed.addAttribute(NSFontAttributeName, value:(NSFont.fontWithName("Helvetica Bold", size:18.0)), range:NSMakeRange(0, package[:name].length))
        attributed.addAttribute(NSParagraphStyleAttributeName, value:paragraph, range:NSMakeRange(0, package[:name].length))
        
        attributed
      else
        "wakka"
    end
  end

  def tableView(tableView, heightOfRow:row)
    60
  end
end