![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/gaofengnan/handy-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/gaofengnan/handy-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/gaofengnan/handy-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/gaofengnan/handy-debian)

<h1>
   <p align="center">
     <a href="https://handy.computer"><img src="https://github.com/gaofengnan/handy-debian/blob/main/handy-logo.png" alt="Handy Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/gaofengnan/handy-debian/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>Handy for Debian
   </p>
</h1>
<p align="center">
 A free, open source, and extensible speech-to-text application that works completely offline.
</p>

# Handy for Debian

> Fork of [dariogriffo/handy-debian](https://github.com/dariogriffo/handy-debian) (MIT); the original packaging is by Dario Griffo. Served at [deb.gaofn.xyz](https://deb.gaofn.xyz) for Debian 12 (bookworm) and 13 (trixie).

This repository contains build scripts to produce the _unofficial_ Debian and
Ubuntu packages (.deb) for [Handy](https://github.com/cjpais/Handy/) hosted at
[deb.gaofn.xyz](https://deb.gaofn.xyz)

The package and the command are both called `handy`. It is a desktop (Tauri)
application: launch it from the application menu, or run `handy`.

Currently supported distros are:
- Debian Bookworm (v12), Trixie (v13), Forky (v14), Sid
- Ubuntu Jammy (22.04), Noble (24.04), Questing (25.10), Resolute (26.04)

Supported architectures:
- amd64 (x86_64) - All distributions
- arm64 (aarch64) - Trixie, Forky, Sid, Noble, Questing and Resolute

Upstream builds its arm64 release on Ubuntu 24.04, so it needs glibc 2.39 and
does not run on Bookworm or Jammy. Upstream only publishes Linux builds for
these two architectures, so there are no i386, armhf, armel or riscv64 packages.

One package per architecture is built and shared by every suite
(`handy_<version>-<build>~griffo_<arch>.deb`). It repackages upstream's own
Linux build: the `handy` binary, its bundled libraries and resources in
`/usr/lib/Handy`, the desktop entry and the icons. The dependencies are
declared so they resolve on every supported suite (including the t64 library
renames), and the text-input helpers Handy shells out to are installed with
it: `xdotool` (X11), `wtype` and `wl-clipboard` (Wayland), plus `ydotool` as a
recommended package (needed on GNOME Wayland; not available on Trixie). The
only change to upstream's files is filling in the launcher's empty menu
category.

Speech models are downloaded from inside the app on first use.

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the Handy source code, see
[Handy](https://github.com/cjpais/Handy/).

## Install/Update

### The Debian way

```sh
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSL https://deb.gaofn.xyz/deb.gaofn.xyz.gpg -o /etc/apt/keyrings/deb.gaofn.xyz.gpg
sudo curl -fsSL https://deb.gaofn.xyz/deb.gaofn.xyz.sources -o /etc/apt/sources.list.d/deb.gaofn.xyz.sources
# Debian 12 (bookworm): fetch deb.gaofn.xyz-bookworm.sources instead
sudo apt update
sudo apt install -y handy
```

### Manual Installation

1. Download the .deb package for your architecture from
   the [Releases](https://github.com/gaofengnan/handy-debian/releases) page.
2. Install it with apt, so the dependencies are pulled in.

```sh
sudo apt install ./<filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Building

### Build for single architecture
```sh
./build.sh <handy_version> <build_version> <architecture>
# Example: ./build.sh 0.9.8 1 arm64
```

### Build for all architectures
```sh
./build.sh <handy_version> <build_version> all
# Example: ./build.sh 0.9.8 1 all
```

## Roadmap

- [x] Produce a .deb package on GitHub Releases
- [x] Set up a debian mirror for easier updates
- [x] Multi-architecture support (amd64, arm64)

## Disclaimer

- This repo is not open for issues related to Handy. This repo is only for _unofficial_ Debian packaging.
