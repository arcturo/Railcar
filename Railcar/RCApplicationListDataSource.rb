#
#  ApplicationListDataSource.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/30/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCApplicationListDataSource
  def initialize
    @applications = ["Winning"] * 3
  end

  def numberOfRowsInTableView(tableView)
    @applications.length
  end

  def tableView(view, objectValueForTableColumn:column, row:index)
    @applications[index]
  end
end