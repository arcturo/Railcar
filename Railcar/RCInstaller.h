//
//  RCInstaller.h
//  Railcar
//
//  Created by Jeremy McAnally on 3/29/12.
//  Copyright (c) 2012 Arcturo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCInstallerDelegate.h"
#import "Constants.h"

@interface RCInstaller : NSObject

@property(strong) id<RCInstallerDelegate> delegate;

- (void) installDependencies;

- (BOOL)checkForCompiler;
- (BOOL)installBrew;
- (BOOL)installRbEnv;
- (BOOL)installRuby;
- (BOOL)installDefaultGems;
- (BOOL)writeShellInitializer;
- (BOOL)needsInstall;

@end
