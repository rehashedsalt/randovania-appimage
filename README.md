# randovania-appimage

A set of build scripts to package [Randovania](https://github.com/randovania/randovania) up into an AppImage

## Usage

Clone the repo, `cd` into it, and run `docker-compose up --build`. There's a Dockerfile in the root of the repository which will configure an Ubuntu 20.04 build image. Other operating systems are possible to build in, but `build.sh` will need to be modified because we use the system-wide Mono to make statically-linked(-ish) binaries out of the patchers.

The output AppImage will be at:

```
out/Randovania-${randovania_git_ref}-amd64.AppImage"
```

## Non-Docker Usage

Clone the repo, `cd` into it, and invoke `build.sh`. See the Dockerfile for build-time dependencies (all of them are). The builder user is not a requirement in non-Docker invocation.

The output AppImage will be at:

```
out/Randovania-${randovania_git_ref}-amd64.AppImage"
```

## Licensing

Code in this repository is licensed under the terms of the GNU General Public License, version 3. See `LICENSE` for more information.

The build artifacts produced by this code contain code from other projects. Namely:

* We distribute Python. Python is licensed under the terms of the [Python Software Foundation License Agreement](https://docs.python.org/3/license.html#psf-license)
* We distribute Randovania. Randovania is licensed under [GPLv3](https://github.com/randovania/randovania/blob/main/LICENSE)
* We redistribute Mono as distributed by Canonical in the Ubuntu repositories. Mono is licensed under the terms of the [MIT License](https://github.com/mono/mono/blob/main/LICENSE)
* We obtain Newtonsoft.Json from NuGet. Newtonsoft.Json is licensed under the terms of the [MIT License](https://github.com/JamesNK/Newtonsoft.Json/blob/master/LICENSE.md). NuGet is not bundled in the output image.

## TODO

* Make the .desktop file in the AppImage actually point to randovania
* Improve these docs
* Trim the heck out of the image, builds right now are like 200MB(!)
* Set up auto-update (and also figure out how to set up auto-update, docs say it's a thing)
 * https://github.com/AppImage/AppImageSpec/blob/master/draft.md#github-releases - Apparently it's a one-line configuration to get it to hook into GH releases
