//
//  Constants.m
//  Railcar
//
//  Created by Jeremy McAnally on 3/29/12.
//  Copyright (c) 2012 Arcturo. All rights reserved.
//

#import "Constants.h"

NSString * const BrewDownloadUrl = @"https://github.com/mxcl/homebrew/tarball/master";

// We use this fork so we can use LLVM if we want; the version we're installing 
// is modern enough
NSString * const ForkTapPath = @"jm/env";

NSString * const DefaultRubyVersion = @"1.9.3-p125";

// Has to be a string because NSArray can't be stored in static memory; I should
// probably just make these variables or in a config file.
NSString * const DefaultGems = @"bundler rails";