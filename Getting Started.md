As I've been getting a lot of questions on how to actually use the scripts in
this repository, here is some more information to get you started.

## Building a portable love distribution using the docker container ##
By far the easiest way to build a portable tarball, AppImage and Snap is by
using the docker container. You can build the container yourself (see `docker
build`) but I recommend saving yourself some time and effort and using the
container from DockerHub. A (complete!) example of how to use this is as
follows:

```sh
docker run --rm -v /path/to/repo:/build/love-linux-builder bartbes/love-linux-builder:x86_64 0.10.2
```

The docker container runs the script located in `docker/build.sh`, but here's a
brief overview:

 - The existing repo is used. Both so you can customise the scripts, or the
   resulting builds see [building portable game distributions][]. The path is
   set using the `-v /path/to/repo:/build/love-linux-builder` argument, as seen
   above. Here the first part is the path to this repo on your local machine,
   and the second part is the destination path in the container. All resulting
   build artifacts end up in the repo.

 - The argument passed to the script (in the example `0.10.2`) is used to
   determine the version for the scripts. If there is no matching tarball, the
   container will build one.

 - If building a tarball, it will first see if `/build/love` contains a
   love(-like) repository. If not, it clones the main love repo. This is a
   customisation point if you want to use a modified build of love. To specify
   your own repo, you can specify an argument to `docker run` as follows:
   `-v /path/to/love-repo:/build/love`

 - The container will now build a Snap and an AppImage. Unfortunately, the
   Flatpak script is not supported, as Flatpak does not run on a distro this
   old.

## Building a portable love distribution manually ##
The first step in getting building portable binaries is getting a tarball. The
rest of the scripts use the tarball as input.

### Building a tarball ###
This is the hardest step of them all. To build a tarball of (mostly) portable
binaries, the key is to use the oldest distro you're willing to support. I, and
the docker container, use Debian Wheezy (aka Debian 7 aka Debian oldoldstable),
as binaries built for it will run on practically any machine reasonably used
for running games.

On said distro, build and install love. It is very likely the distro you
selected does not have (recent) love packages and lacks some dependency, like
SDL2 and LuaJIT. Unfortunately the steps for this are highly distro-specific
(and version-specific), so you're on your own for this bit. If you're building
from source, make sure to run `make install` to install love system-wide.

Once you've got love installed on that machine, running the `build.sh` script
in the tarball directory will extract the love binaries and its dependencies
and copy them to a directory. It also adds a template desktop file, a love icon
and a launcher script that sets up the correct library paths. Surprisingly, it
doesn't actually tar the resulting directory.

*NOTE: The build script also copies in a license.txt file if it exists. For
legal reasons, don't forget to add it!*

The rest of the scripts expect a tarball in the tarball directory, which you
can now create like this:

```sh
tar czf "love-0.10.2-x86_64.tar.gz" dest
```

Substitute the relevant version number and architecture, of course.

### Building an AppImage ###
Now you've got the tarball, most of the hard work is done. Go to the AppImage
directory and run the build script with as single argument the version number
as specified in the tarball name. For example:

```sh
./build.sh 0.10.2
```

It will use the current system architecture as target architecture, so if you
want to build 32-bit binaries on a 64-bit system you can use the `setarch`
program.

NOTE: The AppImage script automatically downloads some binaries if you don't
already have them. In theory, you don't need to install anything to build an
AppImage.

### Building a Flatpak ###
Like the AppImage script, building a Flatpak is as easy as running the script
with the right version. For example:

```sh
./build.sh 0.10.2
```

It will push the resulting data to a Flatpak repo located in `flatpak/repo`
(can be overridden by setting the `REPO` environment variable) and it then
builds a bundle. To build a Flatpak, you will need to have the Flatpak tools
installed.

### Building a Snap ###
The Snap script, surprisingly, works exactly the same as the others. For
example:

```sh
./build.sh 0.10.2
```

Unfortunately, the Snap is the least complete. If you're looking to build a
proper snap, you probably need to customise the YAML file `snap/snap.yaml`.
Like the AppImage script, it requires no snap-specific dependencies, though it
does require the SquashFS tools to be installed (in particular `mksquashfs`).
Most distros provide the tools in their repos, and they're even commonly
pre-installed.

## Building portable game distributions ##
The AppImage and Flatpak scripts provide customisation points so you can build
distributions of your game instead. All these files need to go in the root
directory of the repo.

Both AppImage and Flatpak:

 - `game.love`: A .love file of your game. Will be fused with the love binary
   in the resulting AppImage/Flatpak.

 - `game.desktop.in`: A [desktop file][] for your game. See
   `tarball/love.desktop.in` for inspiration. Note that you want to specify
   `%BINARY%` as application name and `%ICON%` as icon name, since the scripts
   will override these with the relevant paths.

 - `game.svg`: An icon for your game. Used both for the desktop file and for
   the metadata.

Flatpak only:

 - `game.rdns`: A reverse domain name that identifies your game. Love itself
   uses `org.love2d.love`. I *strongly discourage* using the love domain name.
   Please be a nice citizen of the internet and use your own domain name.

 - `game.version`: A version number to display in the application metadata.

For Snap users there is no inbuilt customisation at the moment. You can modify `snap/snap.yaml`.

[building portable game distributions]: #markdown-header-building-portable-game-distributions
[desktop file]: https://standards.freedesktop.org/desktop-entry-spec/latest/
