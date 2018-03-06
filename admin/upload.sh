#!/bin/bash

. build.sh

dist="$HOME/GitHub/ktysd.github.io/"

cp -r _site/* $dist
git add --all ..
git commit -m "build-`date +%Y%m%d`"
git push origin master
