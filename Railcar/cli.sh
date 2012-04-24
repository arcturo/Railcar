#!/bin/sh

# Borrowed trick from Stack Overflow
export RAILCAR_PATH="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

if [ "$1" = "init" ]
then
  init=$(macruby RCCli.rb $@)

  if [ "$init" = "" ]
  then
    echo "You don't have that version of Ruby installed with Railcar!"
    exit 1
  else
    source $init
    export PS1="Railcar ($2) $ "

    echo "Initializing Railcar shell with version $2"
    $SHELL
    exit 0
  fi
fi

# TODO: Find system-wide macruby or use bundled version if it's 
# unavailable.
macruby RCCli.rb $@
