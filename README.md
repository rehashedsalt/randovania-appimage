# randovania-appimage

A set of build scripts to package [Randovania](https://github.com/randovania/randovania) up into an AppImage

## Usage

Clone the repo, `cd` into it, and invoke `build.sh`. The host must have basic Linux tooling such as Bash, wget, rsync, git, etc.

The script will automatically download and extract a release of [python-appimage](https://github.com/niess/python-appimage), extract it, stick a particular ref of Randovania in it, and zip it up.

The output AppImage will be at:

```
out/Randovania-${randovania_git_ref}-amd64.AppImage"
```

## Build Requirements

* A Linux distro with Bash, wget, rsync, git, coreutils, mono-complete, and liblzo2-2

## Runtime Requirements

* Dolphin (if you're running a GameCube game)
* amd64 Linux and X11
* Not Mono

## TODO

* Make the .desktop file in the AppImage actually point to randovania
* Improve these docs
* Trim the heck out of the image, builds right now are like 200MB(!)
* Set up auto-update (and also figure out how to set up auto-update, docs say it's a thing)
 * https://github.com/AppImage/AppImageSpec/blob/master/draft.md#github-releases - Apparently it's a one-line configuration to get it to hook into GH releases
