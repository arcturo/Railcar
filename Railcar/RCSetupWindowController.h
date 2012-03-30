//
//  RCSetupWindowController.h
//  Railcar
//
//  Created by Jeremy McAnally on 3/29/12.
//  Copyright (c) 2012 Arcturo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RCInstallerDelegate.h"
#import "RCInstaller.h"

@interface RCSetupWindowController : NSWindowController <RCInstallerDelegate> {
    IBOutlet NSTextField * label;
    IBOutlet NSTextField * errorLabel;

    IBOutlet NSButton * consoleButton;
    IBOutlet NSButton * installButton;
    
    IBOutlet NSProgressIndicator * progressBar;
    
    RCInstaller * installer;
}

-(void) errorOccurred:(NSString *)errorMessage;
-(void) compilerExists;
-(void) brewInstalled;
-(void) rbEnvInstalled;
-(void) rubyInstalled;
-(void) gemsInstalled;
-(void) noInstallNeeded;

-(IBAction)installEverything:(id)sender;
-(IBAction)openConsole:(id)sender;

@property (strong) RCInstaller * installer;
@property (strong) NSWindow * setupWindow;

@end
