#!/bin/bash

set -eo >/dev/null

if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <version>"
	exit 0
fi

VERSION="$1"
if ! test -f ../tarball/love-${VERSION}-amd64.tar.gz; then
	echo "No tarball found for $VERSION"
	exit 1
fi

if ! which flatpak >/dev/null; then
	echo "Please install flatpak and try again"
	exit 1
fi

# Extract the tarball build into a folder
rm -rf files
mkdir files
tar xf ../tarball/love-${VERSION}-amd64.tar.gz -C files --strip-components=1

cd files

# Add our small wrapper script (yay, more wrappers)
mkdir -p bin
cp ../wrapper bin/wrapper

# Add our desktop file
sed -e 's/%BINPREFIX%love/wrapper/' -e 's/%ICONPREFIX%/org.love2d./' love.desktop.in > ../export/org.love2d.love.desktop
rm love.desktop.in

# "Install" the icon
mv love.svg ../export/org.love2d.love.svg

# Make sure app/lib/GL exists, for the extension mount point
mkdir -p lib/GL

# Now build the final AppImage
cd ..
#rm -rf repo
flatpak build-export repo . ${VERSION}
flatpak build-bundle repo love-${VERSION}-x86_64.flatpak org.love2d.love
