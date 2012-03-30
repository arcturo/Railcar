//
//  RCAppDelegate.m
//  Railcar
//
//  Created by Jeremy McAnally on 3/29/12.
//  Copyright (c) 2012 Arcturo. All rights reserved.
//

#import "RCAppDelegate.h"

@implementation RCAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    RCInstaller * installer = [RCInstaller new];
    
    RCSetupWindowController * windowController = [[RCSetupWindowController alloc] initWithWindowNibName:@"SetupWindow"];
    installer.delegate = windowController;
    windowController.installer = installer;
    
    [[windowController window] makeKeyAndOrderFront:self];
}

@end
