# patches/

MPL-2.0 patch series against the pinned upstream commit in `upstream.lock`.

- Files are `*.patch` in `git diff` format, applied in lexical order (`0001-...`, `0002-...`).
- `office-android.yml` runs `git apply` for each patch inside the upstream checkout, in a step that is skipped when this directory holds no `.patch` files.
- Modified upstream (MPL) files are therefore published here, as the licence requires.

Currently empty.
