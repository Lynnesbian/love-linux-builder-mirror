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

[snap]: http://snapcraft.io/
