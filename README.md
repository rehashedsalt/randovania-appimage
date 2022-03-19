# randovania-appimage

A set of build scripts to package [Randovania](https://github.com/randovania/randovania) up into an AppImage

## Usage

Clone the repo, `cd` into it, and invoke `build.sh`. The host must have basic Linux tooling such as Bash, wget, rsync, git, etc.

The script will automatically download and extract a release of [python-appimage](https://github.com/niess/python-appimage), extract it, stick a particular ref of Randovania in it, and zip it up.

## TODO

* Bundle in Mono (God have mercy on my soul)
* Make the .desktop file in the AppImage actually point to randovania
* Make sure our MetaData is all correct
* Bundle in the Randovania icon
* Improve these docs
* Trim the heck out of the image
