//
//  RCInstaller.m
//  Railcar
//
//  Created by Jeremy McAnally on 3/29/12.
//  Copyright (c) 2012 Arcturo. All rights reserved.
//

#import "RCInstaller.h"

@implementation RCInstaller

@synthesize delegate;

- (BOOL)needsInstall {
    return !([[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/homebrew/rbenv_init.sh", [[NSBundle mainBundle] bundlePath]]]);
}

- (void)installDependencies {
    // Homebrew is already there!
    if ([self needsInstall] == false)
    {
        [delegate noInstallNeeded];
    } else {
        // TODO: Figure out how to tame this.  If we move the delegate actions
        // to the individual methods, then we still have to keep track of things. The 
        // only way to avoid this is really to throw exceptions when the termination status
        // is > 0, but that might be using Exceptions for flow control?  No clue.  This is rough.
        // This is sort of thing is allowed for now. ;)
        if ([self checkForCompiler] == true) {
            NSLog(@"compiler found");
            [delegate compilerExists];
            
            if ([self installBrew] == true) {
                [delegate brewInstalled];
                
                if ([self installRbEnv] == true) {
                    [delegate rbEnvInstalled];
                    
                    if ([self installRuby] == true) {
                        [delegate rubyInstalled];
                        
                        if ([self installDefaultGems] == true) {
                            [self writeShellInitializer];
                            [delegate gemsInstalled];
                        } else {
                            [delegate errorOccurred:@"Gems installation failed."];
                        }
                    } else {
                        [delegate errorOccurred:@"Ruby compilation failed."];
                    }
                } else {
                    [delegate errorOccurred:@"Installing RbEnv failed!"];
                }
            } else {
                [delegate errorOccurred:@"Homebrew installation failed!"];
            }
        } else {
            [delegate errorOccurred:@"Install a compiler!"];
        }
    }
}

- (BOOL)checkForCompiler {
    return [[NSFileManager defaultManager] fileExistsAtPath: @"/usr/bin/cc"];
}

- (BOOL)installBrew {
    // Homebrew is already there!
    if ([[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/homebrew/bin/brew", [[NSBundle mainBundle] bundlePath]]] == true)
    {
        return true;
    }
    
    @try {
        // Install homebrew to the application bundle
        NSLog(@"installing brew...");
        NSTask *installTask = [NSTask new];
        [installTask setLaunchPath:@"/bin/sh"];
        NSString * pathToScript = [[NSBundle mainBundle] pathForResource:@"install_brew" ofType:@"sh"];
        [installTask setArguments:[NSArray arrayWithObjects:pathToScript, BrewDownloadUrl, [[NSBundle mainBundle] bundlePath], nil]];
        
        NSPipe *pipe = [NSPipe pipe];
        [installTask setStandardOutput:pipe];
        [installTask setStandardInput:[NSPipe pipe]];
        [installTask launch];
        
        [[pipe fileHandleForReading] readDataToEndOfFile];
        [installTask waitUntilExit];
        
        if ([installTask terminationStatus] > 0)
        {
            return false;
        }
        
        // Tap our fork of the ruby-build recipe so we can install p125 with XCode 4.2+
        NSLog(@"tapping...");
        NSTask *tapTask = [NSTask new];
        NSString * launchPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"homebrew/bin/brew"];
        [tapTask setLaunchPath:launchPath];
        [tapTask setArguments:[NSArray arrayWithObjects:@"tap", @"jm/env", nil]];
        
        NSPipe *taskPipe = [NSPipe pipe];
        [tapTask setStandardOutput:taskPipe];
        [tapTask setStandardInput:[NSPipe pipe]];
        [tapTask launch];
        
        [[taskPipe fileHandleForReading] readDataToEndOfFile];    
        [tapTask waitUntilExit];
        
        if ([tapTask terminationStatus] > 0)
        {
            return false;
        }
    
        return true;
    } @catch (NSException * exception) {
        return false;
    }
}

- (BOOL)installRbEnv {
    // RbEnv is already there!
    if ([[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/homebrew/Cellar/rbenv/0.3.0/bin/rbenv", [[NSBundle mainBundle] bundlePath]]] == true)
    {
        return true;
    }
    
    @try {
        // Install vanilla rbenv from homebrew
        NSLog(@"installing rbenv...");
        NSString * brewPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"homebrew/bin/brew"];

        NSTask *rbenvTask = [NSTask new];
        [rbenvTask setLaunchPath:brewPath];
        [rbenvTask setArguments:[NSArray arrayWithObjects:@"install", @"rbenv", nil]];
        
        NSPipe *rbenvPipe = [NSPipe pipe];
        [rbenvTask setStandardOutput:rbenvPipe];
        [rbenvTask setStandardInput:[NSPipe pipe]];
        [rbenvTask launch];
        
        [[rbenvPipe fileHandleForReading] readDataToEndOfFile];    
        [rbenvTask waitUntilExit];
        
        if ([rbenvTask terminationStatus] > 0)
        {
            return false;
        }
        
        // Install our fork of ruby-build because we want to be able to use LLVM if they have it instead of straight GCC
        NSLog(@"installing ruby-build-fork...");
        NSTask *buildTask = [NSTask new];
        [buildTask setLaunchPath:brewPath];
        [buildTask setArguments:[NSArray arrayWithObjects:@"install", @"ruby-build-fork", nil]];
        
        NSPipe *buildPipe = [NSPipe pipe];
        [buildTask setStandardOutput:buildPipe];
        [buildTask setStandardInput:[NSPipe pipe]];
        [buildTask launch];
        
        [[buildPipe fileHandleForReading] readDataToEndOfFile];    
        [buildTask waitUntilExit];
        
        if ([buildTask terminationStatus] > 0)
        {
            return false;
        }
        
        return true;
    } @catch (NSException * exception) {
        return false;
    }
}

- (BOOL)installRuby {
    // Ruby is already there!
    if ([[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/homebrew/Cellar/rbenv/0.3.0/versions/%@/bin/ruby", [[NSBundle mainBundle] bundlePath], DefaultRubyVersion]] == true)
    {
        return true;
    }
    
    @try {
        NSString * buildPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"homebrew/Cellar/ruby-build-fork/03292012/bin/ruby-build"];
        NSString * versionPath = [NSString stringWithFormat:@"%@/%@/%@", [[NSBundle mainBundle] bundlePath], @"homebrew/Cellar/rbenv/0.3.0/versions/", DefaultRubyVersion];
        
        // Install Ruby 1.9.3p125.  We use this one because it compiles with LLVM also.
        NSLog(@"installing ruby...");
        NSTask *buildTask = [NSTask new];
        NSDictionary * env = [[NSProcessInfo processInfo] environment];
        [env setValue:@"/usr/bin/gcc" forKey:@"CC"];
        
        [buildTask setEnvironment:env];
        [buildTask setLaunchPath:buildPath];
        [buildTask setArguments:[NSArray arrayWithObjects:DefaultRubyVersion, versionPath, nil]];
        
        NSPipe *buildPipe = [NSPipe pipe];
        [buildTask setStandardOutput:buildPipe];
        [buildTask setStandardInput:[NSPipe pipe]];
        [buildTask launch];
        
        [[buildPipe fileHandleForReading] readDataToEndOfFile];    
        [buildTask waitUntilExit];
        
        if ([buildTask terminationStatus] > 0)
        {
            return false;
        }
        
        return true;
    } @catch (NSException * exception) {
        return false;
    }
}

- (BOOL)installDefaultGems {
    @try {
        NSLog(@"installing gems...");
        NSString * rbenvPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"homebrew/Cellar/rbenv/0.3.0"];

        // Install the default gems
        NSTask *installTask = [NSTask new];
        [installTask setLaunchPath:@"/bin/sh"];
        NSString * pathToScript = [[NSBundle mainBundle] pathForResource:@"install_gems" ofType:@"sh"];
        [installTask setArguments:[NSArray arrayWithObjects:pathToScript, rbenvPath, DefaultGems, nil]];
        
        NSPipe *pipe = [NSPipe pipe];
        [installTask setStandardOutput:pipe];
        [installTask setStandardInput:[NSPipe pipe]];
        [installTask launch];
        
        [[pipe fileHandleForReading] readDataToEndOfFile];
        [installTask waitUntilExit];
        
        if ([installTask terminationStatus] > 0)
        {
            return false;
        }
        
        return true;
    } @catch (NSException * exception) {
        return false;
    }
}

- (BOOL)writeShellInitializer {
    @try {
        NSString * rbenvPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"homebrew/Cellar/rbenv/0.3.0"];
        
        NSString * configuration = [NSString stringWithFormat:@"export RBENV_ROOT=%@\nexport PATH=%@:$PATH\neval \"$(rbenv init -)\"\nexport RBENV_VERSION=\"%@\"\ncd ~\nclear\necho 'Shell setup for Rails -- go nuts!\n'", rbenvPath, [NSString stringWithFormat:@"%@/bin", rbenvPath], DefaultRubyVersion];
        
        NSError * error;
        [configuration writeToFile:[NSString stringWithFormat:@"%@/homebrew/rbenv_init.sh", [[NSBundle mainBundle] bundlePath]] atomically:YES encoding:NSASCIIStringEncoding error:&error];
    } @catch (NSException * exception) {
        return false;
    }
}

@end
