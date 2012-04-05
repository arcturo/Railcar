#
#  RCApplicationManager.rb
#  Railcar
#
#  Created by Jeremy McAnally on 4/2/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCApplicationManager
  def applications
    NSUserDefaults.standardUserDefaults['railcar.linkedApplications'] ||= {}
    NSUserDefaults.standardUserDefaults['railcar.linkedApplications']
  end

  def addApplicationToList(data)
    hsh = NSUserDefaults.standardUserDefaults['railcar.linkedApplications']
    hsh[uniqueId(data)] = data
    NSUserDefaults.standardUserDefaults['railcar.linkedApplications'] = hsh
  end

  def uniqueId(data)
    "#{Time.now.to_i}-#{data[:name].gsub(/\W/, '')}-#{data[:path].gsub(/\W/, '')}"
  end

  def add(path, data = {})
    if isRailsApp?(path)
      addApplicationToList({
        :name => discernAppName(path), 
        :path => path,
        :rubyVersion => DEFAULT_RUBY_VERSION,
        :environment => "development",
        :port => (NSUserDefaults.standardUserDefaults['railcar.linkedApplications'].length + 3001).to_s
      }.merge(data))

      true
    else
      false
    end
  end

  def discernAppName(path)
    pathToRackConfig = File.join(path, "config.ru")

    if File.exist?(pathToRackConfig)
      File.read(pathToRackConfig).split("\n").map do |line| 
        (match = line.match(/run (.*)\:\:Application/)) ? match[1] : nil
      end.compact.first
    else
      path.split("/").last
    end
  end

  def isRailsApp?(path)
    File.exist?(File.join(path, "config", "environment.rb")) && File.exist?(File.join(path, "app", "controllers"))
  end
end