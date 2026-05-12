# Fuzzing with drchaos — NimConf 2022

Presentation and demo for the NimConf 2022 talk on structured, coverage-guided
fuzzing for Nim with [drchaos](https://github.com/status-im/nim-drchaos).

**Speaker:** Antonis Geralis (@planetis)

## Contents

- `deck/` — Typst slide deck (compile with `typst compile --root .. main.typ`)
- `demo.nim` — Graph fuzz target demonstrating drchaos mutators and
  post-processors
- `images/` — Slide assets

## Build the PDF

```sh
cd deck
typst compile --root .. main.typ nimconf2022-drchaos.pdf
```

## References

- [drchaos on GitHub](https://github.com/status-im/nim-drchaos)
- [LibFuzzer documentation](https://llvm.org/docs/LibFuzzer.html)
- [NimConf 2022](https://nim-lang.org/blog/2022/06/24/nim-conference.html)
