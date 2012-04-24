#
#  RCApplicationManager.rb
#  Railcar
#
#  Created by Jeremy McAnally on 4/2/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCApplicationManager
  def appsFile
    File.join((ENV['RAILCAR_PATH'] || NSBundle.mainBundle.bundlePath), "application.yml")
  end
  
  def applications
    if File.exist?(appsFile)
      YAML.load_file(appsFile)
    else
      saveApplicationsList({})
      {}
    end
  end

  def saveApplicationsList(data)
    File.open(appsFile, "w") do |f|
      f.write(YAML.dump(data))
    end
  end

  # We do the persistentDomainForName song and dance so the CLI can use this same code
  def addApplicationToList(data)
    newAppData = {}
    newAppData[uniqueId(data)] = data

    saveApplicationsList(applications.merge(newAppData))
  end

  def appDataForPath(path)
    applications.values.select do |data|
      data[:path] == path
    end.first
  end

  def appDataForName(name)
    applications.values.select do |data|
      data[:name] == name
    end.first
  end

  def uniqueId(data)
    "#{Time.now.to_i}-#{data[:name].gsub(/\W/, '')}-#{data[:path].gsub(/\W/, '')}"
  end

  def add(path, data = {})
    if isRailsApp?(path)
      newAppPort = (applications.empty? ? (applications.length + 3001) : 3000)
      
      addApplicationToList({
        :name => discernAppName(path), 
        :path => path,
        :rubyVersion => DEFAULT_RUBY_VERSION,
        :environment => "development",
        :port => ().to_s
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