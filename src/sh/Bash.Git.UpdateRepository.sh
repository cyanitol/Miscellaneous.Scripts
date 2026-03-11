#!/bin/bash
# Copyright 2022 Justin Weeks <license@jmweeks.com>
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
export DISPLAY=:0.0

#cd ~/Programming/repo
#for repo in $(ls -d ~/Path/to/Programming/repo/*/); do cd $repo; git remote update; cd ~/Programming/repo; done;

for repo in $(find ~/path/to/Programming/repo -name *.git -type d); do 
    cd $repo; git remote update; 
done;
