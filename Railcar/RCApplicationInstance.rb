#
#  RCApplicationInstance.rb
#  Railcar
#
#  Created by Jeremy McAnally on 4/2/12.
#  Copyright 2012 Arcturo. All rights reserved.
#
require 'yaml'
require 'fileutils'

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

  # CLI will feed environment variable if it's available
  def initializerPath
    File.join((ENV['RAILCAR_PATH'] || NSBundle.mainBundle.bundlePath), "initializers", "rbenv_init_#{rubyVersion}.sh")
  end

  def launch
    begin 
      bundleProcessId = Process.spawn("source #{initializerPath}\n bundle install --gemfile=#{path}/Gemfile > /dev/null 2>&1")
      Process.waitpid(bundleProcessId)

      @processId = Process.spawn("source #{initializerPath}\n ruby #{path}/script/rails server -e #{environment} -p #{port}")

      File.open(File.join(path, "tmp", "railcar.pid"), "w") do |f|
        f.write(@processId.to_s)
      end
      
      @launched = true
    rescue
      @launched = false
    end
  end

  def stop
    if (theProcessId = (@processId || File.read(File.join(path, "tmp", "railcar.pid"))))
      begin
        Process.kill("KILL", theProcessId.to_i)
        theProcessId = nil
        FileUtils.rm(File.join(path, "tmp", "railcar.pid")) if File.exists?(File.join(path, "tmp", "railcar.pid"))

        @launched = false
        return true
      rescue
        @launched = false
        return false
      end
    end
  end

  def launched?
    @launched || File.exist?(File.join(path, "tmp", "railcar.pid"))
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

  # TODO: switch this to a delegate setup so I can toss it to another thread
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