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

  # We do the persistentDomainForName song and dance so the CLI can use this same code
  def addApplicationToList(data)
    defaults = NSUserDefaults.standardUserDefaults.persistentDomainForName("com.arcturo.railcar")

    hsh = defaults.dup
    hsh['railcar.linkedApplications'][uniqueId(data)] = data

    NSUserDefaults.standardUserDefaults.setPersistentDomain(hsh, forName: "com.arcturo.railcar")
  end

  def appDataForPath(path)
    appList = NSUserDefaults.standardUserDefaults.persistentDomainForName("com.arcturo.railcar")['railcar.linkedApplications']

    appList.values.select do |data|
      data[:path] == path
    end.first
  end

  def appDataForName(name)
    appList = NSUserDefaults.standardUserDefaults.persistentDomainForName("com.arcturo.railcar")['railcar.linkedApplications']

    appList.values.select do |data|
      data[:name] == name
    end.first
  end

  def uniqueId(data)
    "#{Time.now.to_i}-#{data[:name].gsub(/\W/, '')}-#{data[:path].gsub(/\W/, '')}"
  end

  # We do the persistentDomainForName song and dance so the CLI can use this same code
  def add(path, data = {})
    if isRailsApp?(path)
      defaults = NSUserDefaults.standardUserDefaults.persistentDomainForName("com.arcturo.railcar")

      addApplicationToList({
        :name => discernAppName(path), 
        :path => path,
        :rubyVersion => DEFAULT_RUBY_VERSION,
        :environment => "development",
        :port => (defaults['railcar.linkedApplications'].length + 3001).to_s
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