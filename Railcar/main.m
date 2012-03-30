//
//  main.m
//  Railcar
//
//  Created by Jeremy McAnally on 3/30/12.
//  Copyright (c) 2012 Arcturo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
