#!/bin/bash

set -eo >/dev/null

ARCH="$(uname -m)"

if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <version>"
	exit 0
fi

VERSION="$1"
if ! test -f ../tarball/love-${VERSION}-${ARCH}.tar.gz; then
	echo "No tarball found for $VERSION"
	exit 1
fi

# Extract the tarball build into a folder
rm -rf love-prepared
mkdir love-prepared
tar xf ../tarball/love-${VERSION}-${ARCH}.tar.gz -C love-prepared --strip-components=1

cd love-prepared

# Now add snap stuff
# First, our icon and desktop file
mkdir -p meta/gui
mv love.svg meta/gui/icon.svg
sed -e 's/%BINPREFIX%//' -e '/%ICONPREFIX%/d' love.desktop.in > meta/gui/love.desktop
rm love.desktop.in

# Now the yaml and launcher
sed -e "s/%VERSION%/$VERSION/" ../snap.yaml > meta/snap.yaml
cp ../command-love.wrapper .

# Finally, build it!
mksquashfs . ../love_${VERSION}_${ARCH}.snap -noappend
