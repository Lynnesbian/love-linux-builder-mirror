The script in this git repository can be used (on a sufficiently old linux
system) to extract LÓVE binaries, and turn them into a portable build in
various different formats.

This project is split up into multiple parts, and each part is responsible for
a different build. Note that the `tarball` build is used as a base for the
other builds.

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

NOTE: I haven't been able to run the built snaps yet, but that seems to be a
driver issue, possibly related to Arch Linux. Let me know if it works for you!

## appimage ##
`appimage` builds [AppImages][AppImage], unsurprisingly. It uses binaries from
[AppImageKit][], though you can build them yourself if you want to. And hey,
this actually seems to work, too!

## flatpak ##
`flatpak` is used to build [flatpak][] "packages". It requires the flatpak
command line tool. Of course flatpak has some kind of repo system, so you can't
easily distribute a flatpak file. Useful.

NOTE: Once again driver issues (blame nvidia) prevent me from testing this
myself. If you get it working, let me know!

[snap]: http://snapcraft.io/
[AppImage]: http://appimage.org/
[AppImageKit]: https://github.com/probonopd/AppImageKit
[flatpak]: http://flatpak.org/
