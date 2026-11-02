# cloud-init patches

FreeBSD patches applied by `scripts/cloud-init.sh` to the cloud-init source
before installing it into the venv. `patch-*` files are applied in alphabetical
order with `patch -p0` from the top of the source tree.

## Origin

Taken from the FreeBSD port [net/cloud-init](https://github.com/freebsd/freebsd-ports/tree/2a7c0561200c6cf9d0c0252cd4a7ab446eca8e4a/net/cloud-init/files)
(cloud-init 25.2, freebsd-ports commit `2a7c0561200c`):

| File here | Port file | Change |
| --- | --- | --- |
| `patch-cloudinit_distros_freebsd.py` | `extra-cloudinit_distros_freebsd.py` | home directories in `/home` |
| `patch-cloudinit_netinfo.py` | `extra-cloudinit_netinfo.py` | accept exit code 64 of FreeBSD 15 `netstat` |
| `patch-cloudinit_settings.py` | `patch-cloudinit_settings.py` | config in `/usr/local/etc/cloud`, `%%PREFIX%%` replaced by `/usr/local` |

The port's `patch-setup.py` is not needed, `scripts/cloud-init.sh` installs the
config and rc.d files itself. Its `patch-config_cloud.cfg.d_99__freebsd.cfg`
is written by `scripts/cloud-init.sh` as `99_freebsd.cfg`.

## Updating cloud-init or adding patches

1. Set `CLOUD_INIT_VERSION` and `CLOUD_INIT_SHA256` in `scripts/cloud-init.sh`.
2. Compare with the port's `files/` for that version and copy new or changed
   patches here as `patch-*`, replacing `%%PREFIX%%` with `/usr/local`. Patches
   of our own go here the same way, in the same `-p0` format.
3. Check they apply to the new source:
   `for p in patch-*; do patch -p0 --dry-run -d <source dir> < $p; done`
4. Update the table above.
