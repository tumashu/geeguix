#!/run/current-system/profile/bin/bash

export GUIX_PACKAGE_PATH=$HOME/geeguix
guix home reconfigure $HOME/geeguix/geehome/home.cfg
