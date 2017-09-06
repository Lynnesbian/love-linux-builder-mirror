#!/bin/bash

CURRENT_APPIMAGEKIT_RELEASE=9

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

download_if_needed() {
	if ! test -f "$1"; then
		if ! curl -L -o "$1" "https://github.com/AppImage/AppImageKit/releases/download/${CURRENT_APPIMAGEKIT_RELEASE}/$1"; then
			echo "Failed to download appimagetool"
			echo "Please supply it manually"
			exit 1
		fi
		chmod +x "$1"
	fi
}

download_if_needed appimagetool-x86_64.AppImage
download_if_needed AppRun-x86_64

# Extract the tarball build into a folder
rm -rf love-prepared
mkdir love-prepared
tar xf ../tarball/love-${VERSION}-amd64.tar.gz -C love-prepared --strip-components=1

cd love-prepared

# Add our small wrapper script (yay, more wrappers), and AppRun
cp ../wrapper usr/bin/wrapper-love
cp ../AppRun-x86_64 AppRun

# Add our desktop file
sed -e 's/%BINPREFIX%/wrapper-/' -e 's/%ICONPREFIX%//' love.desktop.in > love.desktop
rm love.desktop.in

# Add a DirIcon
cp love.svg .DirIcon

# Now build the final AppImage
cd ..

# Work around missing FUSE/docker
./appimagetool-x86_64.AppImage --appimage-extract
./squashfs-root/AppRun love-prepared love-${VERSION}-x86_64.AppImage
