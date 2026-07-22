# ICU Data for `deno_core`

The data file is derived from Rusty V8's `third_party/icu/common/icudtl.dat`
(Chromium's prebuilt ICU data), with Blink-only items stripped — data that
Chromium needs but V8 never reads (verified: no `ucnv_`/`uspoof_`/`uidna_`/
`utrans_` calls anywhere in V8), saving ~1.07 MB (9.9%):

- legacy charset converters (`*.cnv`, `cnvalias.icu`) — Blink HTML legacy
  encodings; Deno uses `encoding_rs`
- `uts46.nrm` (IDNA) — Deno uses the Rust `idna` crate
- `confusables.cfu` — Chrome's URL spoof checker
- `translit/*` — transliteration, unused by V8

All remaining items are byte-identical to the upstream file. To regenerate
from a new upstream `icudtl.dat`:

```sh
./tools/update_data.sh /path/to/icudtl.dat
```

The `icupkg` version must match the data's major version (for example,
`icudt77l` requires ICU 77). Set `ICUPKG=/path/to/icupkg` if the matching tool
is not on `PATH`.

`--ignore-deps` is needed because Chromium's upstream file already has
dangling resource references, e.g. `rbnf/ja.res` → `rbnf/root.res`; the
stripping above introduces no new ones.
