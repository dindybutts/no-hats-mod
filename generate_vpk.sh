#!/usr/bin/env bash
#
# generate_vpk.sh
#
# Copyright (C) 2020 dindybutts <lewdavatar at gmail dot com>
#
# Distributed under terms of the GPLv3 license.
#

set -o errexit
set -o nounset

# check if we have a virtual env, if not we create one
if [ ! -d ".venv" ]; then
  python -m venv .venv
fi

# enter the virtual environment
source .venv/bin/activate

if [ ! -x "$(command -v vpk)" ]; then
  pip install -r requirements.txt
fi
# generates a list of all the files
if [ ! -f "filelist.txt" ]; then
  echo "Generating filelist"
  # dear lord this regex is absolutely disgusting
  REGEX="^model.*/((player|(workshop|workshop_partner\/player))\/items\/(all_class|demo|engineer|heavy|medic|mvm_loot|pyro|scout|sniper|soldier|spy)).*vtx"
  vpk -re "$REGEX" -l "$HOME"/.steam/steam/steamapps/common/Team\ Fortress\ 2/tf/tf2_misc_dir.vpk > filelist.txt
fi

# read filelist.txt into a variable and then create/touch all dirs/empty files
if [ ! -d "output/" ]; then
  echo "Building directory structure"
  FILES=$(<filelist.txt)
  for FILE in $FILES; do
    mkdir -p output/"${FILE%/*}"
    touch output/"$FILE"
  done
fi

# actually create the vpk file from the "output" directory
echo "Creating vpk file"
vpk -c output nohats-"$(date --iso-8601)".vpk
