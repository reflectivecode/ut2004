# ut2004
A dedicated Unreal Tournament 2004 server

[![docker](https://github.com/reflectivecode/ut2004/actions/workflows/docker.yml/badge.svg)](https://github.com/reflectivecode/ut2004/actions/workflows/docker.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/reflectivecode/ut2004.svg)](https://hub.docker.com/r/reflectivecode/ut2004/)

The image is published to both `ghcr.io/reflectivecode/ut2004` and Docker Hub as `reflectivecode/ut2004`.

## Quickstart

This sample starts a CTF match and enables the web interface at http://localhost:8080/. Replace `<choose-a-password>` with your own admin password.

```
docker run -d \
    --name ut2004 \
    -p 7777:7777/udp \
    -p 7778:7778/udp \
    -p 127.0.0.1:8080:80 \
    -v ut2004-data:/home/ut2004/.ut2004 \
    -e "CONFIG_1=[Engine.AccessControl];AdminPassword=<choose-a-password>;[UWeb.WebServer];bEnabled=True" \
    -e "UT2004_CMD=CTF-FACECLASSIC?game=XGame.xCTFGame" \
    ghcr.io/reflectivecode/ut2004
```

The web interface uses plain HTTP, so the sample only publishes it on localhost. Don't expose port 80 to the internet; reach it over SSH or a VPN instead.

## Features

* Fully patched dedicated server, with both 32-bit and 64-bit binaries
* Support for downloading and installing addons (maps, mutators, etc)
* Support for configuring advanced ini settings
* Support for compressing addons for serving via nginx, apache, etc
* Support for web interface

## Ports

| Port | Purpose |
|---|---|
| `7777/udp` | Game traffic |
| `7778/udp` | Server queries |
| `80` | Web interface (if enabled) |

## Data

Settings and downloaded addons are stored in `/home/ut2004/.ut2004`. Mount a volume there, as in the quickstart, to keep them when the container is replaced.

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `UT2004_CMD` | `CTF-FACECLASSIC?game=XGame.xCTFGame` | Map and URL options passed to `ucc server` |
| `UT2004_ARCH` | `32` | Server binary to run: `32` or `64` |
| `CONFIG_n` | | ini settings to apply on startup, in the form `[Section];Key=Value;` (n = 1 to 100) |
| `CONFIG_n_FILE` | `UT2004.ini` | ini file that `CONFIG_n` applies to |
| `CONFIG_n_DELIMIT` | `;` | Separator used in `CONFIG_n` |
| `DOWNLOAD_n_URL` | | Addon archive to download and install (n = 1 to 100) |
| `DOWNLOAD_n_SHA1` | | SHA1 checksum of the archive; required with `DOWNLOAD_n_URL` |
| `DOWNLOAD_n_FILE` | | Filename of the archive, used to detect its type (.zip, .7z, .tar, .tar.gz, .tar.bz2); required with `DOWNLOAD_n_URL` |
| `DOWNLOAD_n_DEST_DIR` | `.` | Directory under `/home/ut2004/.ut2004` to extract into |
| `DOWNLOAD_n_SRC_DIR` | `.` | Only extract this directory from the archive |
| `COMPRESS_DIR` | | If set, addons are compressed to `.uz2` files in this directory |

### 32-bit and 64-bit

The 32-bit server is the default because it is the most widely tested build and works with addons that include 32-bit native libraries. Set `UT2004_ARCH=64` to run the 64-bit server instead.

### Addons

Each `DOWNLOAD_n` archive is downloaded, checked against its SHA1 checksum, and extracted into `/home/ut2004/.ut2004`. An archive is only installed once per checksum, so restarts don't download it again.

```
-e "DOWNLOAD_1_URL=https://example.com/MyMaps.zip" \
-e "DOWNLOAD_1_SHA1=<sha1 of MyMaps.zip>" \
-e "DOWNLOAD_1_FILE=MyMaps.zip"
```

### Compressed downloads

By default, players download missing files through the game connection, which is slow. For faster downloads, set `COMPRESS_DIR` to a mounted directory and serve it with a separate web server such as nginx (the built-in web interface can't serve these files). Then point players at it:

```
-e "CONFIG_2=[IpDrv.HTTPDownload];RedirectToURL=http://example.com/ut2004/;UseCompression=True;"
```

## Known limitations

Epic's master servers have been shut down, so the server won't appear in the in-game server browser unless you configure a community master server.
