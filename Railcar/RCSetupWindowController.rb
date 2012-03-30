class RCSetupWindowController < NSWindowController
  attr_accessor :label, :errorLabel, :consoleButton, :installButton, :progressBar, :installer

  def windowDidLoad
    super
    
    if installer.needsInstall?
      consoleButton.setEnabled(false)
    else
      noInstallNeeded
    end
  end

  def errorOccurred(message)
    label.setStringValue ""
    errorLabel.setStringValue message
    progressBar.setDoubleValue 0.0
  end

  def compilerExists
    label.setStringValue "Compiler found!  Installing brew..."
    progressBar.incrementBy 10.0
  end

  def brewInstalled
    label.setStringValue "Brew installed!  Installing rbenv..."
    progressBar.incrementBy 25.0
  end

  def rbenvInstalled
    label.setStringValue "RbEnv installed!  Installing ruby... (This will take a while!)"
    progressBar.incrementBy 15.0
  end

  def rubyInstalled
    label.setStringValue "Ruby installed!  Installing default gems..."
    progressBar.incrementBy 39.0
  end

  def gemsInstalled
    label.setStringValue "All setup!!"
    progressBar.setDoubleValue 100.0
    progressBar.stopAnimation self

    consoleButton.setEnabled true
  end

  def noInstallNeeded 
    label.setStringValue "You're already setup.  Proceed!"
    progressBar.setDoubleValue 100.0
    progressBar.stopAnimation self
    
    consoleButton.setEnabled true
    installButton.setEnabled false
  end

  def installEverything(sender)
    installButton.setEnabled false
    progressBar.performSelectorOnMainThread("startAnimation:", withObject:self, waitUntilDone:false)

    installer.performSelectorInBackground("installDependencies", withObject:nil)
  end

  def openConsole(sender)
    pathToInitializer = File.join(NSBundle.mainBundle.bundlePath, "homebrew", "rbenv_init.sh")
    
    NSWorkspace.sharedWorkspace.openFile("~/", withApplication:"Terminal");
    command = "tell application \"Terminal\" to do script \"source #{pathToInitializer}\""
    
    scriptRunner = NSAppleScript.alloc.initWithSource(command)
    scriptRunner.executeAndReturnError(nil)
  end

end
