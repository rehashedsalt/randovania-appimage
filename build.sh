#! /bin/bash
#
# build.sh
# Builds Randovania into an AppImage
#
# This script is mostly built on this guide from AppImageKit:
# https://github.com/AppImage/AppImageKit/wiki/Bundling-Python-apps
#
# Copyright (C) 2022 Salt <jacob@babor.tech>
# Distributed under terms of the GNU General Public License, Version 3
#

set -e

# Configuration vars
workdir="work"
python_appimage="https://github.com/niess/python-appimage/releases/download/python3.9/python3.9.10-cp39-cp39-manylinux1_x86_64.AppImage"
randovania_location="/opt/randovania"
randovania_git_uri="https://github.com/randovania/randovania"
randovania_git_ref="v4.1.1"

# Derived/static vars
AppRun="squashfs-root/AppRun"

# Make our working directory, cd in
mkdir -p "$workdir"
pushd "$workdir"
AppRun="$PWD/$AppRun"

# Set debugging mode from here on
set -x

# Grab the base Python AppImage and extract it
# We'll add Mono on top of it later
wget "$python_appimage"
chmod +x python*-manylinux1_x86_64.AppImage
./python*-manylinux1_x86_64.AppImage --appimage-extract

# Grab Randovania, check out the ref we want
git clone "$randovania_git_uri" randovania
git -C randovania fetch --tags
git -C randovania checkout "$randovania_git_ref"

# Make a directory for Randovania and sync it over
mkdir -p squashfs-root/"$randovania_location"
rsync -aHS --exclude={.git} randovania/ squashfs-root/"$randovania_location"

# Install Randovania
pushd squashfs-root/"$randovania_location"
tools/prepare_virtual_env.sh
# I'm not building a whole release just to get this one json file lol
cat > randovania/data/configuration.json << EOF
{"discord_client_id": 618134325921316864, "server_address": "https://randovania.metroidprime.run/randovania", "socketio_path": "/randovania/socket.io"}
EOF
popd

# We're all wrapped up; time to modify AppRun to start Randovania
sed -ie 's|"$@"|"-m" "randovania"|g'
