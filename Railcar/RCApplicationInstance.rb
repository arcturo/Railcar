#
#  RCApplicationInstance.rb
#  Railcar
#
#  Created by Jeremy McAnally on 4/2/12.
#  Copyright 2012 Arcturo. All rights reserved.
#
require 'yaml'

class RCApplicationInstance
  attr_accessor :name, :path, :rubyVersion, :port, :environment, :key, :processId

  def initialize(key, data)
    @key = key

    @name = data[:name]
    @path = data[:path]
    @rubyVersion = data[:rubyVersion]
    @port = data[:port]
    @environment = data[:environment]
  end

  def initializerPath
    File.join(NSBundle.mainBundle.bundlePath, "initializers", "rbenv_init_#{rubyVersion}.sh")
  end

  def launch
    begin 
      @processId = Process.spawn("source #{initializerPath} \n ruby #{path}/script/rails server -e #{environment} -p #{port}")
    
      @launched = true
    rescue
      @launched = false
    end
  end

  def stop
    if @processId
      begin
        Process.kill("KILL", @processId)
        @processId = nil
        
        @launched = false
        return true
      rescue
        @launched = false
        return false
      end
    end
  end

  def launched?
    @launched
  end

  def environments
    (Dir.entries(File.join(@path, "config", "environments")) - [".", ".."]).map {|f| f.split("\.").first}.reject {|i| i.empty?}
  end

  # TODO: It would be cool to make this smarter (e.g., "MySQL database `xyz`, using ActiveRecord"
  # or "MongoDB database `abc` using Mongoid")
  def databaseInfo
    if (File.exist?(File.join(@path, "config", "database.yml")))
      info = YAML.load_file(File.join(@path, "config", "database.yml"))[@environment || "development"]

      "#{info['adapter']} database `#{info['database']}`"
    elsif (File.exist?(File.join(@path, "config", "mongo.yml")))
      "MongoDB database"
    else
      "Unknown"
    end
  end

  def versionControlStatus
    if (File.exist?(File.join(@path, ".git")))
      gitStatus
    elsif (File.exist?(File.join(@path, ".svn")))
      svnStatus
    elsif (File.exist?(File.join(@path, ".hg")))
      hgStatus
    else
      {:name => "(none)", :status => "No version control."}
    end
  end

  def gitStatus
    status = `cd #{@path} && git status`
    
    statusText = if (status =~ /working directory clean/)
      "Clean (nothing to commit or push)."
    elsif (status =~ /Your branch is ahead of/im)
      "You have changes to pull in your local copy!"
    elsif (status =~ /Changes to be committed/im)
      "You have some changes staged that need to be pushed."
    elsif (status =~ /Changes not staged for commit/im)
      "You have some changes that aren't staged for pushing yet."
    else
      "Not sure!"
    end

    {:name => "Git", :status => statusText}
  end

  def svnStatus
    # TODO: implement this.
    {:name => "Subversion", :status => "It ain't Git."}
  end

  def hgStatus
    # TODO: implement this.
    {:name => "Mercurial", :status => "You ain't gitt'in it...yet."}
  end
end