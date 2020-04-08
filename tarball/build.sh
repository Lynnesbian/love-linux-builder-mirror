#!/bin/bash

DEST="$(pwd)/dest"
declare -a libpaths=()

getdeps()
{
	ldd "$1" | awk '{print $3}'
}

systemlib()
{
	case "$(basename "$1")" in
		libc.so* | \
		libm.so* | \
		libdl.so* | \
		librt.so* | \
		libpthread.so* | \
		libstdc++.so* )
			return 0
			;;
		*)
			return 1
			;;
	esac
}

copy()
{
	# Skip system libraries
	if ! test -f "$1" || systemlib "$1"; then
		echo "Skipping $1"
		return
	fi

	# Copy files to their paths, with $DEST as prefix (so /usr/lib -> $DEST/usr/lib)
	echo "Copying $1"
	mkdir -p "$DEST/$(dirname "$1")"
	cp "$1" "$DEST/$1"
	libpaths+=("$(dirname "$1")")
}

main()
{
	local appbin="$(which "$1")"
	local appname="$(basename "$appbin")"

	# Now copy all binaries and libraries
	copy "$appbin"
	for dep in $(getdeps "$appbin"); do
		copy "$dep"

		# Copy libstdc++ into its own location
		if grep -qF 'libstdc++.so.6' <<< "$dep"; then
			mkdir -p "$DEST/libstdc++/"
			cp "$dep" "$DEST/libstdc++/"
		fi
	done

	# Build LD_LIBRARY_PATH string
	local libpath=""
	while read path; do
		if [[ "$libpath" != "" ]]; then
			libpath="$libpath:"
		fi
		libpath="${libpath}\${LOVE_LAUNCHER_LOCATION}$path" # TODO
	done <<< "$(printf '%s\n' "${libpaths[@]}" | sort -u)"

	# Generate wrapper
	(
		printf '#!/bin/sh\n'
		printf 'export LOVE_LAUNCHER_LOCATION="$(dirname "$(which "$0")")"\n'
		printf 'export LD_LIBRARY_PATH="%s:$LD_LIBRARY_PATH"\n' "$libpath"
		printf '/sbin/ldconfig -p | grep -q libstdc++ || export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${LOVE_LAUNCHER_LOCATION}/libstdc++/"\n'
		printf 'exec ${LOVE_BIN_WRAPPER} "${LOVE_LAUNCHER_LOCATION}%s" "$@"\n' "$appbin"
	) > "$DEST/$appname"
	chmod +x "$DEST/$appname"

	# Add our icon and prototype desktop file
	cp "$appname.desktop.in" "$DEST"
	cp "$appname.svg" "$DEST"

	# And the license file, if it exists
	if test -f "license.txt"; then
		cp "license.txt" "$DEST"
	else
		echo "No license.txt file found, downloading from GitHub"
		curl "https://raw.githubusercontent.com/love2d/love/${VERSION}/license.txt" -o "$DEST/license.txt"
	fi
}

main love
