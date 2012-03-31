#
#  RCAvailablePackages.rb
#  Railcar
#
#  Created by Jeremy McAnally on 3/31/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCAvailablePackages
  PACKAGES = {
    "db" => [
      {
        :name => "MySQL", 
        :description => "The most popular open-source SQL database",
        :image => "mysql.png",
        :brew_name => "mysql"
      },
      {
        :name => "PostgreSQL",
        :description => "High-capacity, high-performance SQL database",
        :image => "pgsql.png",
        :brew_name => "postgresql"
      },
      {
        :name => "MongoDB",
        :description => "Document-oriented database",
        :image => "mongo.png",
        :brew_name => "mongodb"
      }
    ]
  }
  
  def self.inCategory(category)
    PACKAGES[category]
  end
end