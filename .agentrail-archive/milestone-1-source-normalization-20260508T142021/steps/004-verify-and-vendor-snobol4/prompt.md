Verify sw-embed/sw-cor24-snobol4#1 (SIZE/SUBSTR/CHAR) is actually
resolved end-to-end and produce a runnable snobol4 wrapper in this
repo so subsequent saga work (normalize.sno onward) can actually
execute.

1. Build sw-cor24-snobol4 to produce build/snobol4.bin. Recon:
   - tc24r is on PATH (/disk1/.../bin/tc24r)
   - cor24-run is on PATH
   - link24 + meta-gen Rust sources are in
     /disk1/.../dcpls/.../sw-cor24-plsw/components/linker/{src,Cargo.toml}
     but the binaries are NOT built. snobol4's build-modular.sh
     hardcodes a $HOME/github/... path that does not exist for this
     user.
   Build the linker binaries (cargo build --release in the linker
   crate). Decide a clean way to make them visible to the snobol4
   build (env var override, symlink, or copy) without editing the
   sibling repo's source.

2. Run `just build` (or scripts/build-modular.sh) in sw-cor24-snobol4
   to produce build/snobol4.bin.

3. Write a tiny SNOBOL4 test program that exercises SIZE, SUBSTR, and
   CHAR. Run it via cor24-run + snobol4.bin and confirm correct
   output.

4. Add scripts/snobol4 in THIS repo: a wrapper that invokes the
   built snobol4 binary via cor24-run, taking a .sno file path and
   reading FTI-0 source from stdin, per docs/tools.md.

5. Update docs/snobol4-blockers.md with the verification result --
   either 'verified resolved' (with how-to-use details for future
   agents) or 'new blockers discovered' (with concrete details and
   what would unblock).

Acceptance:
- scripts/snobol4 exists and runs a tiny .sno program end-to-end
- docs/snobol4-blockers.md reflects current truth
- All edits stay within this repo (NO WORKAROUNDS: do not modify
  source in sibling repos; only build and run them).

If anything fails irrecoverably, document precisely what failed in
docs/snobol4-blockers.md and `agentrail abort --reason ...` referencing
it.