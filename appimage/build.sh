#!/bin/bash

set -eo >/dev/null

CURRENT_APPIMAGEKIT_RELEASE=12
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

main() {
	download_if_needed appimagetool-${ARCH}.AppImage
	download_if_needed AppRun-${ARCH}

	# Extract the tarball build into a folder
	rm -rf love-prepared
	mkdir love-prepared
	tar xf ../tarball/love-${VERSION}-${ARCH}.tar.gz -C love-prepared --strip-components=1

	cd love-prepared

	# Add our small wrapper script (yay, more wrappers), and AppRun
	cp ../wrapper usr/bin/wrapper-love
	cp ../AppRun-${ARCH} AppRun

	local desktopfile="love.desktop"
	local icon="love"
	local target="love-${VERSION}"

	if test -f ../../game.desktop.in; then
		desktopfile="game.desktop"
		cp ../../game.desktop.in .
	fi
	if test -f ../../game.svg; then
		icon="game"
		cp ../../game.svg .
	fi
	if test -f ../../game.love; then
		target="game"
		cat usr/bin/love ../../game.love > usr/bin/love-fused
		mv usr/bin/love-fused usr/bin/love
		chmod +x usr/bin/love
	fi

	# Add our desktop file
	sed -e 's/%BINARY%/wrapper-love/' -e "s/%ICON%/${icon}/" "${desktopfile}.in" > "$desktopfile"
	rm "${desktopfile}.in"

	# Add a DirIcon
	cp "${icon}.svg" .DirIcon

	# Clean up
	if test -f ../../game.desktop.in; then
		rm love.desktop.in
	fi
	if test -f ../../game.svg; then
		rm love.svg
	fi

	# Now build the final AppImage
	cd ..

	# Work around missing FUSE/docker
	./appimagetool-${ARCH}.AppImage --appimage-extract
	./squashfs-root/AppRun love-prepared "${target}-${ARCH}.AppImage"
}

main "$@"
