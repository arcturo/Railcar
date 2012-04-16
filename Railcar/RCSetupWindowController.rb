class RCSetupWindowController < NSWindowController
  attr_accessor :label, :errorLabel, :controlButton, :progressBar, :installer, :sourceCheckbox, :brewTitle, :brewInfo, :rbenvTitle, :rbenvInfo, :rubyTitle, :rubyInfo, :packagesTitle, :packagesInfo

  def windowDidLoad
    super
    
    if !installer.needsInstall?
      noInstallNeeded
    end
  end

  def windowWillClose(sender)
    NSApp.stopModal
  end

  def errorOccurred(message)
    errorLabel.setStringValue message
    progressBar.setDoubleValue 0.0
  end

  def compilerExists
    highlight(brewTitle, brewInfo)
    brewTitle.setStringValue "Installing Homebrew"

    progressBar.incrementBy 10.0
  end

  def brewInstalled
    fade(brewTitle, brewInfo)
    brewTitle.setStringValue "Homebrew installed"

    highlight(rbenvTitle, rbenvInfo)
    rbenvTitle.setStringValue "Installing RbEnv"

    progressBar.incrementBy 25.0
  end

  def rbenvInstalled
    fade(rbenvTitle, rbenvInfo)
    rbenvTitle.setStringValue "RbEnv installed"

    highlight(rubyTitle, rubyInfo)
    rubyTitle.setStringValue "Installing Ruby 1.9.3"

    progressBar.incrementBy 15.0
  end

  def rubyInstalled
    fade(rubyTitle, rubyInfo)
    rubyTitle.setStringValue "Ruby installed"

    highlight(packagesTitle, packagesInfo)
    packagesTitle.setStringValue "Installing default packages"

    progressBar.incrementBy 39.0
  end

  def gemsInstalled
    fade(packagesTitle, packagesInfo)
    packagesTitle.setStringValue "Default packages installed"

    progressBar.setDoubleValue 100.0
    progressBar.stopAnimation self

    controlButton.setTitle("Let's go!")
    controlButton.setEnabled(true)
    window.makeFirstResponder(controlButton)
  end

  def controlButtonClick(sender)
    if installer.needsInstall?
      installEverything
    else
      hideMe
    end
  end

  def noInstallNeeded 
    label.setStringValue "You're already setup.  Proceed!"
    progressBar.setDoubleValue 100.0
    progressBar.stopAnimation self
    
    controlButton.setEnabled false
  end

  def hideMe
    NSApp.stopModal
  end

  def installEverything
    fade(brewTitle, brewInfo, rbenvTitle, rbenvInfo, rubyTitle, rubyInfo, packagesTitle, packagesInfo)

    controlButton.setEnabled false
    sourceCheckbox.setEnabled false
    progressBar.performSelectorOnMainThread("startAnimation:", withObject:self, waitUntilDone:false)

    installer.performSelectorInBackground("installDependencies", withObject:(sourceCheckbox.state == 1))
  end

  def fade(*controls)
    controls.each {|control| control.setTextColor(NSColor.grayColor)}
  end

  def highlight(*controls)
    controls.each {|control| control.setTextColor(NSColor.blackColor)}
  end
end
