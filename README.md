# quiredocs-engine

Native engine builds for the Quire Docs mobile app: the LibreOffice/Collabora Online mobile core (office documents), PDFium + qpdf (PDF), built in GitHub Actions and published as versioned release artifacts (`engine-vX.Y.Z`).

Licensed under the Mozilla Public License 2.0 (see `LICENSE`). Modified MPL files from upstream projects are published here as required by the MPL.

## Android bridge (`android-bridge/`)

`QuireLOBridge.java` is the MPL-2.0 file the Quire Docs app compiles into package `org.libreoffice.androidlib` to drive the unmodified engine AAR (`LOActivity`'s JNI bridge) from a native view instead of an Activity. It subclasses `LOActivity`, is never started, and overrides the two native callbacks (`rawCallFakeWebsocketOnMessage`, `postMobileMessage`). No upstream file is modified, so no `patches/` are needed for it; the app's copy must stay identical to this one.
