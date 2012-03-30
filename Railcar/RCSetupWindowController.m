//
//  RCSetupWindowController.m
//  Railcar
//
//  Created by Jeremy McAnally on 3/29/12.
//  Copyright (c) 2012 Arcturo. All rights reserved.
//

#import "RCSetupWindowController.h"

@implementation RCSetupWindowController

@synthesize installer;
@synthesize setupWindow;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    if ([installer needsInstall] == true) {
        [consoleButton setEnabled:NO];
    
        [setupWindow makeFirstResponder:installButton];
    } else {
        [self noInstallNeeded];
    }
}

-(void) errorOccurred:(NSString *)errorMessage {
    [label setStringValue:@""];
    [errorLabel setStringValue:errorMessage];
    [progressBar setDoubleValue:0.0];
}

-(void) compilerExists {
    [label setStringValue:@"Compiler found!  Installing brew..."];
    [progressBar incrementBy:10.0];
}

-(void) brewInstalled {
    [label setStringValue:@"Brew installed!  Installing rbenv..."];
    [progressBar incrementBy:25.0];
}

-(void) rbEnvInstalled {
    [label setStringValue:@"RbEnv installed!  Installing ruby... (This will take a few minutes!)"];
    [progressBar incrementBy:15.0];
}

-(void) rubyInstalled {
    [label setStringValue:@"Ruby installed!  Installing default gems..."];
    [progressBar incrementBy:39.0];
}

-(void) gemsInstalled {
    [label setStringValue:@"All setup!!"];
    [progressBar setDoubleValue:100.0];
    [progressBar stopAnimation:self];

    [[NSSound soundNamed:@"burn complete"] play];
    [consoleButton setEnabled:YES];
}

-(void) noInstallNeeded {
    [label setStringValue:@"You're already setup.  Proceed!"];
    [progressBar setDoubleValue:100.0];
    [progressBar stopAnimation:self];
    
    [consoleButton setEnabled:YES];
    [installButton setEnabled:NO];
}

-(IBAction)installEverything:(id)sender {
    [installButton setEnabled:NO];
    [progressBar performSelectorOnMainThread:@selector(startAnimation) withObject:self waitUntilDone:NO];

    [installer performSelectorInBackground:@selector(installDependencies) withObject:nil];
}

-(IBAction)openConsole:(id)sender {
    NSString * pathToInitializer = [NSString stringWithFormat:@"%@/homebrew/rbenv_init.sh", [[NSBundle mainBundle] bundlePath]];
    
    [[NSWorkspace sharedWorkspace] openFile:@"~/" withApplication:@"Terminal"];
    NSString *s = [NSString stringWithFormat:
                   @"tell application \"Terminal\" to do script \"source %@\"", pathToInitializer];
    
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource: s];
    [as executeAndReturnError:nil];
}

@end
