#!/bin/bash

function f_pretty_print {
  echo -e "\e[1;32m $1\e[0m"
}

function f_check_error {
  if [ "$2" != "" ]; then
    f_pretty_print "$1"
    exit 1
  fi
}

COMPILE_GERRIT="yes"
GERRIT_BRANCH=
TARGET_FOLDER=

pushd /home/vagrant/workspace

if [ "$COMPILE_GERRIT" -eq "yes" ]; then
  f_pretty_print "Cloning gerrit ..."
  git clone ssh://jello@sigmadesigns.com/tools/gerrit.git
  
  f_pretty_print "Checkout ${GERRIT_BRANCH} ..."
  git checkout -b ${GERRIT_BRANCH} ${GERRIT_BRANCH}
  
  f_pretty_print "Compiling gerrit package ..."
  mvn package
fi

f_pretty_print "Installing gerrit ..."
#java -jar gerrit/gerrit-war/target/gerrit-<version>-***.war init -d ${TARGET_FOLDER}

popd

