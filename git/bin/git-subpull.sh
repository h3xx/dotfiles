#!/bin/sh

git submodule foreach -q --recursive 'echo $name:;git checkout "$(git config -f $toplevel/.gitmodules submodule.$name.branch)"; git pull -r; echo'
