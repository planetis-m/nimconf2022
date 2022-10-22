import nimib, nimiSlides, strutils

nbInit(theme = revealTheme)

template nimConfTheme() =
  ## Running this will give a dark background, yellow headings and yellow list bullets
  setSlidesTheme(Black)
  let nimYellow = "#FFE953"
  nb.addStyle: """
:root {
  --r-background-color: #181922;
  --r-heading-color: $1;
  --r-link-color: $1;
  --r-selection-color: $1;
  --r-link-color-dark: darken($1 , 15%)
}

.reveal ul, .reveal ol {
  display: block;
  text-align: left;
}

li::marker {
  color: $1;
  content: "»";
}

li {
  padding-left: 12px;
}
""" % [nimYellow]

nimConfTheme()

slide:
  cornerImage("https://github.com/nim-lang/assets/raw/master/Art/logo-crown.png", UpperRight, size=100, animate=false)
  nbText: """
## Fuzzing with [drchaos](https://github.com/status-im/nim-drchaos)
Antonis Geralis – @planetis
"""
  speakerNote: """

"""

slide:
  slide:
    nbText: """
## What will be covered
- What is drchaos and how it works
- Explain a few fuzz targets
- Write a target from scratch
"""
    speakerNote: """

"""
  slide:
    nbText: """
## What is fuzzing?
> Fuzzing is a testing technique that involves providing random data as inputs to a program.
> The program is then monitored for crashes, failed assertions, and memory leaks.

– [Fuzzing](https://en.wikipedia.org/wiki/Fuzzing) on Wikipedia
"""
    speakerNote: """

"""
  slide:
    nbText: "## Why you need a fuzzer"
    speakerNote: """

"""
slide:
  slide:
    nbText: """
## What is drchaos?
LibFuzzer + AddressSanitizer + drchaos
"""
    speakerNote: """

"""
  slide:
    nbImage("../images/profchaos1.gif")
    speakerNote: """

"""
  slide:
    nbText: "feed to software under test"
    nbImage("../images/profchaos2.gif")
    speakerNote: """
creating problems for the patrons.
"""
  slide:
    nbText: """
in all seriousness...

TLV input + Custom Mutator
"""
    nbImage("../images/what_is.png")
    speakerNote: """

"""

slide:
  slide:
    nbText: "## Explain some fuzz targets"
    speakerNote: """
(ttuple.nim)
"""
  slide:
    nbText: "## Demo time!"
    speakerNote: """

"""

slide:
  nbText: """
## Future directions?
- Refactor? Experiment with a different mutators architecture.
- Fuzzing stateful APIs, based on interfaces, acquiring seed corpus from use.
- Will be used to power an offline simulation of the Ethereum blockchain.
"""
speakerNote: """

"""

slide:
  nbText: """
## Thanks
- [zah](https://github.com/zah) works for [Status](https://github.com/status-im), funded drchaos
- [disruptek](https://github.com/disruptek) sponsor
- [HugoGranstrom](https://github.com/HugoGranstrom), [pietroppeter](https://github.com/pietroppeter) made nimiSlides
"""
  speakerNote: """

"""

nbSave()
