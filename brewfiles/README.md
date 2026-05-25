# Per-Machine Brewfiles

Each Mac keeps its own Homebrew bundle under `brewfiles/<hostname>/Brewfile`, where `<hostname>` is the short hostname (`hostname -s`, e.g. `stardewvalley`).

## Commands

```bash
# Dump only (frequent updates)
./setup.sh brew-backup

# Install packages for this machine
./setup.sh brew-install

# Full backup still includes brew-backup
./setup.sh backup
```

## New machine / full recover

`./setup.sh full-recover` runs `brew-install` automatically when a Brewfile exists for the current hostname.

## Hostname changed?

Point at another machine's Brewfile:

```bash
BREWFILE_HOST=other-mac ./setup.sh brew-install
```
