love-linux-git
---
## This is a fork!
This project was forked from [the original BitBucket repo](https://bitbucket.org/bartbes/love-linux-builder/), which hasn't been updated in some time. Currently, the Docker image provided by that repo fails to build, as the Mercurial version that it tries to use dies when connecting to bitbucket.org because it can't complete the SSLv3 handshake (which is a good thing). I've fixed this by updating the Dockerfile to use [Debian OldStable](https://wiki.debian.org/DebianOldStable) instead of [Debian Jessie](https://wiki.debian.org/LTS/Jessie). As of the time of writing, Debian OldStable is [Debian Stretch](https://wiki.debian.org/DebianStretch). Debian Stretch was originally released 3 years ago, and uses Linux kernel version 4.9, meaning that any Löve binaries created should be compatible with any Linux system that was updated within the last 3 or so years.

## License

The original repo did not provide a license, meaning by default it is copyrighted by the author. I assume that the author did not intend this, and am releasing this fork under the MIT license. Please don't sue me!

## The rest

The original README is as follows:

The script in this git repository can be used (on a sufficiently old linux
system) to extract LÓVE binaries, and turn them into a portable build in
various different formats.

This project is split up into multiple parts, and each part is responsible for
a different build. Note that the `tarball` build is used as a base for the
other builds.

See [Getting Started][] for more information on how to use these scripts.

## tarball ##
`tarball` contains a build script that extracts the love version currently
installed on the system together with its dependencies to form a portable
build. It also creates a small wrapper script that does the correct search path
manipulations to be able to run the build.

Lastly, it contains the icon and a stubbed desktop file.

## snap ##
`snap` builds.. well, a [snap][]. Instead of using fancy build tools that try
to do everything for you, why not just do it manually?! Seriously though, you
can still use snapcraft to build this, but at that point it just acts like a
fancy mksquashfs, and an extra dependency at that.

NOTE: Due to nvidia driver issues I haven't been able to test these snaps yet.
From what I can tell these issues have been fixed since the last time I tried.
Let me know if you get them working so I can remove this note.

## appimage ##
`appimage` builds [AppImages][AppImage], unsurprisingly. It uses binaries from
[AppImageKit][], though you can build them yourself if you want to. And hey,
this actually seems to work, too!

## flatpak ##
`flatpak` is used to build [flatpak][] "packages". It requires the flatpak
command line tool. Of course flatpak has some kind of repo system, so you can't
easily distribute a flatpak file. Useful.

## docker ##
`docker` does not build docker images. Instead it builds a docker image so you
can build portable packages yourself!

To build the container, you need to download the relevant SDL2 and LuaJIT
source packages (and possibly update the references in the Dockerfile).

To use the container, run it as an application, mounting this repo as
/build/love-linux-builder. You can optionally mount love source at /build/love,
and if no source is provided it clones the repo and checks out the specified
version. Note that the container requires exactly one argument: the version.
This can be an arbitrary string, but for cloning to work it needs to be a tag,
branch or commit.

[snap]: http://snapcraft.io/
[AppImage]: http://appimage.org/
[AppImageKit]: https://github.com/probonopd/AppImageKit
[flatpak]: http://flatpak.org/
[Getting Started]: Getting%20Started.md
