//
//  RCInstallerDelegate.h
//  Railcar
//
//  Created by Jeremy McAnally on 3/29/12.
//  Copyright (c) 2012 Arcturo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RCInstallerDelegate <NSObject>

-(void) errorOccurred:(NSString *)errorMessage;
-(void) compilerExists;
-(void) brewInstalled;
-(void) rbEnvInstalled;
-(void) rubyInstalled;
-(void) gemsInstalled;
-(void) noInstallNeeded;

@end
