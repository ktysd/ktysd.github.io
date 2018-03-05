#!/bin/bash

. build.sh

git add --all ..
git commit -m "build-`date +%Y%m%d`"
git push origin master
