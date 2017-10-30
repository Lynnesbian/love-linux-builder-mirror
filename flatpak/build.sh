#!/bin/bash

set -eo >/dev/null

ARCH="$(uname -m)"
REPO="${REPO:-repo}"

if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <version>"
	exit 0
fi

VERSION="$1"
if ! test -f ../tarball/love-${VERSION}-${ARCH}.tar.gz; then
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
tar xf ../tarball/love-${VERSION}-${ARCH}.tar.gz -C files --strip-components=1
cd files

# The export dir contains metadata for the host
rm -r ../export
mkdir ../export

# If we're packaging a game, move its data in place and extract the relevant metadata
target="love-${VERSION}"
targetversion="$VERSION"
rdns="org.love2d.love"

if test -f ../../game.rdns && test -f ../../game.version; then
	rdns="$(cat ../../game.rdns)"
	targetversion="$(cat ../../game.version)"

	if test -f ../../game.desktop.in; then
		cp ../../game.desktop.in love.desktop.in
	fi

	if test -f ../../game.svg; then
		cp ../../game.svg love.svg
	fi

	if test -f ../../game.love; then
		target="game"
		cat usr/bin/love ../../game.love > usr/bin/love-fused
		mv usr/bin/love-fused usr/bin/love
		chmod +x usr/bin/love
	fi
fi

# Add our desktop file
sed -e 's|%BINARY%|/app/love|' -e "s/%ICON%/${rdns}/" love.desktop.in > "../export/${rdns}.desktop"
rm love.desktop.in

# "Install" the icon
mv love.svg "../export/${rdns}.svg"

# Make sure app/lib/GL exists, for the extension mount point (no longer needed?)
mkdir -p lib/GL

# Process metadata.in
cd ..
sed -e "s/%RDNS%/${rdns}/" metadata.in > metadata

# Now build the final AppImage
#rm -rf repo
flatpak build-export "$REPO" . "$targetversion"
flatpak build-bundle "$REPO" "${target}-${ARCH}.flatpak" "$rdns" "$targetversion"
