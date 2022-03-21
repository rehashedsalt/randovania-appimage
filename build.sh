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
outdir="out"

python_appimage="https://github.com/niess/python-appimage/releases/download/python3.9/python3.9.10-cp39-cp39-manylinux1_x86_64.AppImage"
appimagetool_appimage="https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
nuget_url="https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"

randovania_location="/opt/randovania"
randovania_git_uri="https://github.com/randovania/randovania"
randovania_git_ref="v4.1.1"

mono_mkbundle_args="-v --simple --static --no-machine-config --no-config --deps"
mono_mkbundle_args="$mono_mkbundle_args --library $(ldconfig -p | grep 'liblzo2.so' | head -n 1 | awk '{print $4}')"
# Note: the name libmono-system-native.so here is a Debianism.
# Other distributions may use libmono-native.so instead.
mono_mkbundle_args="$mono_mkbundle_args --library $(ldconfig -p | grep 'libmono-system-native.so' | head -n 1 | awk '{print $4}')"
mono_mkbundle_args="$mono_mkbundle_args -L /usr/lib/mono/4.5"

# Derived/static vars
AppRun="squashfs-root/AppRun"

# Make our working directory, cd in
mkdir -p "$workdir"
mkdir -p "$outdir"
pushd "$workdir"
AppRun="$PWD/$AppRun"

# Set debugging mode from here on
set -x

# Grab the base Python AppImage and extract it
# We'll add Mono on top of it later
wget "$python_appimage"
chmod +x python*-manylinux1_x86_64.AppImage
./python*-manylinux1_x86_64.AppImage --appimage-extract

# Add squashfs-root/usr/bin to the front of PATH so the right python
# interp gets used for the build process
PATH="$PWD"/squashfs-root/usr/bin:"$PATH"
which python

# Grab Randovania, check out the ref we want
git clone "$randovania_git_uri" randovania
git -C randovania fetch --tags
git -C randovania checkout "$randovania_git_ref"

# Make a directory for Randovania in the image and sync it over
mkdir -p squashfs-root/"$randovania_location"
rsync -a --exclude={.git} randovania/ squashfs-root/"$randovania_location"

# Sync in our overlay
rsync -a ../overlay/ squashfs-root/

# Bundle up our Mono apps to avoid having to redistribute the Mono runtime
# This depends on a few things on the host:
#
#  - There's a hardcoded library path at the top of the script for liblzo2
#    That file needs to be present.
#
#  - The .config files that add a dllmap for liblzo2 are required at build time
#
#  - The host has to have mono-complete installed (package name is a debianism,
#    but the long and short of it is that you need the full runtime and dev
#    tooling
#
#  - The host has a glibc version >= that of the platform in $mono_target
#
#  - The CLIENT has a glibc version >= that of the platform in $mono_target. I
#    set it to what I did because it's almost a guarantee that that should be
#    the case
#
# If all goes well, you'll get a static binary that runs on anything, no Mono
# runtime required. No futzing with liblzo2 required. Just Werks.

# EchoesMenu.exe
pushd squashfs-root/"$randovania_location"/randovania/data/ClarisEchoesMenu
mkbundle $mono_mkbundle_args --config EchoesMenu.exe.config EchoesMenu.exe -o echoes-menu
popd

# Randomizer.exe
# This one is slightly more complex, as we have to add several dependencies
# via nuget.exe since they're either third-party or just straight up not
# included in the cross-compile runtimes for some reason
wget "$nuget_url"
mkdir nuget
mono nuget.exe install NewtonSoft.json -OutputDirectory nuget
#mono nuget.exe install Novell.Directory.Ldap -OutputDirectory nuget
nugetdir="$PWD/nuget"
pushd squashfs-root/"$randovania_location"/randovania/data/ClarisPrimeRandomizer/
mkbundle $mono_mkbundle_args --config Randomizer.exe.config Randomizer.exe -o randomizer \
	-L "$nugetdir"/Newtonsoft.Json.*/lib/net45 \
	-L "$nugetdir"/Novell.Directory.Ldap.*/lib
popd

# Install Randovania
pushd squashfs-root/"$randovania_location"
tools/prepare_virtual_env.sh
# Drop to a subshell to build the UI real quick
(
	. venv/bin/activate
	python setup.py build_ui
)
# I'm not building a whole release just to get this one json file lol
cat > randovania/data/configuration.json << EOF
{"discord_client_id": 618134325921316864, "server_address": "https://randovania.metroidprime.run/randovania", "socketio_path": "/randovania/socket.io"}
EOF
popd

# Remove configuration from the upstream python AppImage
rm \
	squashfs-root/usr/share/applications/python*.desktop \
	squashfs-root/usr/share/icons/hicolor/256x256/apps/python*.png \
	squashfs-root/usr/share/metainfo/python*.appdata.xml \
	squashfs-root/python*.desktop \
	squashfs-root/python*.png
# Trim the fat
rm -rf \
	squashfs-root/opt/randovania/.git* \
	squashfs-root/opt/randovania/pylintrc \
	squashfs-root/opt/randovania/requirements* \
	squashfs-root/opt/randovania/setup.cfg \
	squashfs-root/opt/randovania/venv/lib/python3.9/site-packages/PySide2/Qt/lib/libQt5WebEngineCore.so.5 \
	squashfs-root/opt/randovania/venv/lib/python3.9/site-packages/PySide2/Qt/translations/qtwebengine_locales

# And finally build our AppImage!
wget "$appimagetool_appimage"
chmod +x appimagetool*.AppImage
./appimagetool-x86_64.AppImage squashfs-root ../"$outdir"/"Randovania-$randovania_git_ref-amd64.AppImage"
