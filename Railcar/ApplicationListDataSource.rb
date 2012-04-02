#
#  ApplicationListDataSource.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/30/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class ApplicationListDataSource
  def initialize
    @applications = ["Winning"]
  end

  def numberOfRowsInTableView(tableView)
    @applications.length
  end

  def objectValueForTableColumn(tableColumn, row)
    @applications[row]
  end
end