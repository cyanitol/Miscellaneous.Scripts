#!/bin/bash
# Copyright 2022 Justin Weeks <license@jmweeks.com>

#cd ~/Programming/repo
#for repo in $(ls -d ~/Path/to/Programming/repo/*/); do cd $repo; git remote update; cd ~/Programming/repo; done;

for repo in $(find ~/path/to/Programming/repo -name *.git -type d); do 
    cd $repo; git remote update; 
done;
