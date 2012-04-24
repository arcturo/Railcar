#!/bin/sh

#  install_brew.sh
#  Railcar
#
#  Created by Jeremy McAnally on 3/29/12.
#  Copyright (c) 2012 Arcturo. All rights reserved.
cd $2
curl -L $1 | tar xz --strip 1 -C homebrew