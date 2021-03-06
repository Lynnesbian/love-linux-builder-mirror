#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Usage: $0 <version>"
	exit 0
fi

VERSION="$1"
ARCH="$(uname -m)"

cd /build/love-linux-builder

msg() {
	printf "\033[1m· %s\033[0m\n" "$1"
}

buildlove() {
	pushd ../love

	if ! test -d ./src; then
		msg "Source not found, checking out from repo"

		hg clone https://bitbucket.org/rude/love .
		hg update "${VERSION}"
	fi

	if ! test -f ./configure; then
		msg "Running automagic"
		./platform/unix/automagic
	fi

	msg "Running configure"
	./configure --prefix=/usr

	msg "Running make"
	make -j`nproc` all install

	popd
}

buildtarball() {
	pushd tarball

	./build.sh

	tar czf "love-${VERSION}-${ARCH}.tar.gz" dest

	popd
}

buildsnap() {
	pushd snap

	./build.sh "${VERSION}"

	popd
}

buildappimage() {
	pushd appimage

	./build.sh "${VERSION}"

	popd
}

buildflatpak() {
	pushd flatpak

	./build.sh "${VERSION}"

	popd
}

if ! test -f "tarball/love-${VERSION}-${ARCH}.tar.gz"; then
	msg "Building love"
	buildlove
	buildtarball
else
	msg "Binaries found, skipping love build"
fi


msg "Building snap"
buildsnap

msg "Building appimage"
buildappimage

msg "Building flatpak"
buildflatpak
