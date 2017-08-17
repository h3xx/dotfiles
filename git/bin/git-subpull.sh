#!/bin/sh

git submodule foreach -q --recursive 'echo $name:; git fetch --all && git checkout "$(git config -f $toplevel/.gitmodules submodule.$name.branch)" && git merge --ff-only && echo'
