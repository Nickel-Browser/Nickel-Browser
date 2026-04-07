# Legacy Source-Build Scripts

The scripts in this directory are for the obsolete 35GB source-build process. They are kept here for historical reference and advanced developers.

**For 99% of users, please use the recommended Binary Repagging method (Method A) as described in [BUILD.md](../BUILD.md).**

---

## Scripts List

- `apply_patches.sh`: Applies Nickel patches to Chromium source.
- `build.sh`: Compiles Chromium using Ninja.
- `create-swap.sh`: Creates a swap file for low-RAM systems.
- `degoogle_chromium.sh`: Removes Google services from Chromium.
- `fetch-chromium.sh`: Downloads Chromium source tree (~35GB).
- `package.sh`: Packages the compiled browser.
- `setup.sh`: Installs build dependencies.
