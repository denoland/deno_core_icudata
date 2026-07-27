# ICU Data for `deno_core`

The data file is derived from Rusty V8's `third_party/icu/common/icudtl.dat`
(Chromium's prebuilt ICU data), with resources not used by V8 stripped:

- legacy charset converters (`*.cnv`, `cnvalias.icu`) — Blink HTML legacy
  encodings; Deno uses `encoding_rs`
- `uts46.nrm` (IDNA) — Deno uses the Rust `idna` crate
- `confusables.cfu` — Chrome's URL spoof checker
- `translit/*` — transliteration, unused by V8
- `rbnf/*` — ICU rule-based number formatting; ECMA-402 does not expose
  algorithmic numbering systems
- `nfkc_scf.nrm` — ICU's NFKC Simple Casefold API, which V8 does not call
  (`nfkc_cf.nrm` remains because RegExp Unicode properties use it)
- `ulayout.icu` — Indic layout and vertical-orientation properties that V8
  does not expose
- `currencyNumericCodes.res` — ISO numeric currency codes, unused by V8
- `genderList.res` — ICU `GenderInfo`, unused by V8
- `windowsZones.res` — Windows/IANA time-zone conversion, unused by V8
- `icuver.res` — ICU data-version query metadata, unused by V8
- `icustd.res` — an unreferenced standard-data marker bundle

All remaining package items are byte-identical to the upstream file. To
regenerate from a new upstream `icudtl.dat`:

```sh
./tools/update_data.sh /path/to/icudtl.dat
```

The `icupkg` version must match the data's major version (for example,
`icudt77l` requires ICU 77). Set `ICUPKG=/path/to/icupkg` if the matching tool
is not on `PATH`.

`--ignore-deps` is needed because Chromium's upstream file already has
dangling resource references, e.g. `brkitr/root.res` →
`brkitr/title.brk`; the stripping above introduces no new ones.
