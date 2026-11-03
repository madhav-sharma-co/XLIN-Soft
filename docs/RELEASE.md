# Making a release

1. Make sure CI is green on `main` and `bin/xlin` has the right `XLIN_VERSION`.
2. `git tag -a v0.1.0 -m "Xlin-soft 0.1.0" && git push origin v0.1.0`
3. On GitHub: Releases -> Draft a new release -> choose the tag -> paste the newest CHANGELOG section as the notes.
4. Add two or three screenshots (light and dark desktop, Launcher, Settings).
5. Optional: `scripts/release.sh` builds `../xlin-<version>.tar.gz` to attach.
