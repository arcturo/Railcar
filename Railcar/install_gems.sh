#!/bin/sh

#  install_gems.sh
#  Railcar
#
#  Created by Jeremy McAnally on 3/29/12.
#  Copyright (c) 2012 Arcturo. All rights reserved.

export RBENV_ROOT=$1
$1/bin/rbenv init
$1/bin/rbenv local 1.9.3-p125
$1/bin/rbenv exec gem install --no-rdoc --no-ri $2