#
#  RCCli.rb
#  Railcar
#
#  Created by Jeremy McAnally on 4/19/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

# TODO: Clean some of this up!

require 'Configuration'
require 'RCApplicationManager'
require 'RCApplicationInstance'
require 'RCRubyManager'

class RCCli
  class CommandNotFoundError < StandardError; end
  class BadUsageError < StandardError
    attr_accessor :command

    def initialize(cmd)
      @command = cmd.class
    end
  end

  class Command
    class <<self
      attr_accessor :commands, :command_description, :command_usage, :command_name
      
      def inherited(sub)
        @commands ||= {}
        # They really need a Class#bare_name or something...
        sub.command_name = sub.name.split('::').last.downcase
        @commands[sub.command_name] = sub
      end

      def execute(args)
        if (command = @commands[args.shift])
          command.new.execute(args)
        else
          raise CommandNotFoundError
        end
      end

      def description(desc)
        @command_description = desc
      end

      def usage(desc)
        @command_usage = desc
      end
    end

    def execute(args)
      raise "Implement me!"
    end
  end

  class Add < Command
    description "Add an application to the Railcar app list"
    usage "[path]"

    # TODO: Take args like --port etc.
    def execute(args)
      raise BadUsageError.new(self) unless (args.length == 1) 

      puts "Adding [#{args.first}] to Railcar..."
      if RCApplicationManager.new.add(args.first)
        puts "Done!"
      else
        puts
        puts "That path (#{args.first}) doesn't appear to exist or be a Rails application."
        puts "Make sure you've got the path right!"
        puts
      end
    end
  end

  class Launch < Command
    description "Launch an application that is in the Railcar app list"
    usage "[path || app_name]"

    def execute(args)
      appData = if File.exist?(args.first)
        RCApplicationManager.new.appDataForPath(args.first)
      else
        RCApplicationManager.new.appDataForName(args.first)
      end

      if appData
        appInstance = RCApplicationInstance.new(appData[:name], appData)
        
        puts
        if appInstance.launched?
          puts "That app is already running!"
          puts "If you know it's not running, delete #{appData[:path]}/tmp/railcar.pid and try again."
          puts

          exit
        end

        if appInstance.launch
          puts "Launched!"
          puts "Wait a few seconds and you can view it here: http://localhost:#{appInstance.port}"
        else
          puts "There was an error launching your application.  Check the logs!"
        end
        puts
      else
        puts
        puts "Can't find path or app named [#{args.first}]."
        puts
      end
    end
  end

  class Stop < Command
    description "Stop an application launched by Railcar"
    usage "[path || app_name]"

    def execute(args)
      appData = if File.exist?(args.first)
        RCApplicationManager.new.appDataForPath(args.first)
      else
        RCApplicationManager.new.appDataForName(args.first)
      end

      if appData
        appInstance = RCApplicationInstance.new(appData[:name], appData)
        
        puts

        unless appInstance.launched?
          puts "That app isn't running or isn't controlled by Railcar!"
          puts

          exit
        end

        if appInstance.stop
          puts "Stopped #{appInstance.name}."
        else
          puts "There was an error stopping your application.  Check the logs!"
        end
        puts
      else
        puts
        puts "Can't find path or app named [#{args.first}]."
        puts
      end
    end
  end

  class Init < Command
    description "Initialize a Railcar environment in the current shell"
    usage "[version]"

    def execute(args)
      path = File.join(RCRubyManager.new.initializersPath, "rbenv_init_#{args.first}.sh")

      if File.exist?(path)
        print path
      else
        print ""
      end
    end
  end

  class Install < Command
    description "Install a Ruby version or Homebrew package"
    usage "[package_name || ruby_version]"
  end

  def initialize(args)
    begin
      Command.execute(args)
    rescue CommandNotFoundError
      puts "\nSorry, Railcar doesn't have that command."
      puts
      puts "Maybe you meant one of these: "
      puts Command.commands.keys.join(", ")
      puts
    rescue BadUsageError => e
      puts "\nSorry, you're not quite using that command correctly."
      puts
      puts "Command description: #{e.command.command_description}"
      puts "Usage: railcar #{e.command.command_name} #{e.command.command_usage}\n\n"
    end
  end
end

RCCli.new(ARGV)