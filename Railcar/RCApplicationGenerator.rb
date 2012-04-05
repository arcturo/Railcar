#
#  RCApplicationGenerator.rb
#  Railcar
#
#  Created by Jeremy McAnally on 4/4/12.
#  Copyright 2012 Arcturo. All rights reserved.
#

class RCApplicationGenerator
  attr_accessor :delegate

  DB_ADAPTERS = {
    "MySQL" => "mysql",
    "PostgreSQL" => "pg",
    "Sqlite" => "sqlite3"
  }

  def initialize(viewController)
    @view = viewController
  end

  def initializerPath(version)
    File.join(NSBundle.mainBundle.bundlePath, "initializers", "rbenv_init_#{version}.sh")
  end

  def generate
    @flags = []

    generateFlags

    completePath = File.join(@view.pathField.stringValue, @view.nameField.stringValue)

    command = "source #{initializerPath(@view.versionSelector.selectedItem.title)} \n rails new #{completePath} #{@flags.join(' ')}"
    
    processId = Process.spawn(command)
    Process.waitpid(processId)

    File.exist?(completePath) ? delegate.generationComplete(completePath) : delegate.generationError
  end

  def generateFlags
    setDatabaseFlags
    setAssetPipelineFlag
    setBundlerFlags
    setGitFlag
    setTestingFlag
  end

  def setDatabaseFlags
    # TODO: Kill this regex by using a tag or something instead
    @flags << "-d #{DB_ADAPTERS[@view.databaseSelector.selectedItem.title.gsub(/ \(not installed with Railcar\)/, '')]}"
    @flags << "-O" if (@view.skipActiveRecordCheckbox.state == 1)
  end

  def setAssetPipelineFlag
    @flags << "-S" if (@view.skipAssetPipelineCheckbox.state == 1)
  end

  def setBundlerFlags
    @flags << "--skip-bundle" if (@view.skipBundlerCheckbox.state == 1)
    @flags << "--skip-gemfile" if (@view.skipBundlerCheckbox.state == 1)
  end

  def setGitFlag
    @flags << "-G" if (@view.gitFileCheckbox.state == 1)
  end

  def setTestingFlag
    @flags << "-T" if (@view.testingSelector.selectedItem.title != "MiniTest/Test::Unit")
  end
end