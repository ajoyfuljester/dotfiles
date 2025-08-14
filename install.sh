#!/usr/bin/env bash

# NOTE: this is not a complete file

# TODO: install yay

# TODO: install dependecties... i probably won't add this for a while


echo "creating symlinks..."

cd $XDG_CONFIG_DIRS

ln -sf $XDG_CONFIG_DIRS/gtkcss/_colors.scss ./astal/_colors.scss
ln -sf $XDG_CONFIG_DIRS/gtkcss/_bgfg.scss ./astal/_bgfg.scss
ln -sf $XDG_CONFIG_DIRS/gtkcss/_h-bgfg.scss ./astal/_h-bgfg.scss

ln -sf $XDG_CONFIG_DIRS/gtkcss/_colors.scss ./gtkgreet/_colors.scss

ln -sf $XDG_CONFIG_DIRS/gtkcss/_colors.scss ./wofi/_colors.scss

ln -sf $XDG_CONFIG_DIRS/gtkcss/_colors.scss ./swaync/_colors.scss


echo "finished!"
