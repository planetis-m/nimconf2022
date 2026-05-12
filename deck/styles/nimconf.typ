#let colors = (
  ink: rgb("#0f1218"),
  ink-2: rgb("#151922"),
  paper: rgb("#eee9df"),
  panel: rgb("#181d26"),
  panel-2: rgb("#202632"),
  text: rgb("#f1ede3"),
  muted: rgb("#aaa59a"),
  dim: rgb("#747a83"),
  nim: rgb("#d7b84b"),
  nim-2: rgb("#9d8230"),
  cyan: rgb("#78a9ae"),
  green: rgb("#8da37b"),
  red: rgb("#b9665e"),
  violet: rgb("#9b8bb4"),
  line: rgb("#343b49"),
  code-bg: rgb("#090c11"),
)

#let fonts = (
  sans: "Liberation Sans",
  mono: "Liberation Mono",
)

#let deck-title = "Fuzzing with drchaos"
#let deck-subtitle = "Structured fuzzing for Nim"
#let assets = (
  logo: "../../images/nim-conf-2022.svg",
  stack: "../../images/what_is.png",
)

#let apply-theme() = {
  set page(width: 16in, height: 9in, margin: 0pt, fill: colors.ink)
  set text(font: fonts.sans, fill: colors.text, size: 23pt)
  set par(leading: 0.72em)
  set heading(numbering: none)
  show link: set text(fill: colors.nim)
  show strong: set text(fill: colors.nim)
  show emph: set text(fill: colors.cyan)
}

#let _bg(section: none) = {
  place(top + left)[#rect(width: 100%, height: 100%, fill: colors.ink)]
  place(top + left)[#rect(width: 100%, height: 100%, fill: colors.ink-2.transparentize(68%))]

  place(top + right, dx: -0.56in, dy: 0.38in)[
    #text(size: 9.5pt, fill: colors.dim, weight: "semibold", tracking: 0.04em)[NIMCONF 2022]
  ]
}

#let _footer(section: none) = {
  place(bottom + right, dx: -0.58in, dy: -0.34in)[
    #text(size: 10pt, fill: colors.dim)[
      #if section != none { upper(section) + " / " }
      #context counter(page).display()
    ]
  ]
}

#let slide(title: none, kicker: none, section: none, body) = {
  _bg(section: section)
  pad(left: 0.86in, right: 1.14in, top: 0.68in, bottom: 0.74in)[
    #if kicker != none [
      #text(size: 9.5pt, fill: colors.cyan, weight: "semibold", tracking: 0.08em)[#upper(kicker)]
      #v(0.14in)
    ]
    #if title != none [
      #text(size: 36pt, weight: "bold", fill: colors.text)[#title]
      #v(0.26in)
    ]
    #body
  ]
  _footer(section: section)
  pagebreak()
}

#let closing-slide(title: none, kicker: none, section: none, body) = {
  _bg(section: section)
  pad(left: 0.86in, right: 1.14in, top: 0.68in, bottom: 0.74in)[
    #if kicker != none [
      #text(size: 9.5pt, fill: colors.cyan, weight: "semibold", tracking: 0.08em)[#upper(kicker)]
      #v(0.14in)
    ]
    #if title != none [
      #text(size: 36pt, weight: "bold", fill: colors.text)[#title]
      #v(0.26in)
    ]
    #body
  ]
  _footer(section: section)
}

#let title-slide(title, subtitle, byline, body) = {
  place(top + left)[#rect(width: 100%, height: 100%, fill: colors.ink)]
  place(top + left)[#rect(width: 100%, height: 100%, fill: colors.ink-2.transparentize(68%))]
  place(top + left, dx: 0.86in, dy: 0.78in)[
    #text(size: 11pt, fill: colors.dim, weight: "semibold", tracking: 0.10em)[NIMCONF 2022]
  ]
  place(right + horizon, dx: -1.40in)[
    #image(assets.logo, width: 4.0in)
  ]
  pad(left: 0.86in, right: 6.10in, top: 2.10in, bottom: 0.76in)[
    #text(size: 58pt, weight: "bold", fill: colors.text)[#title]
    #v(0.10in)
    #text(size: 24pt, fill: colors.muted)[#subtitle]
    #v(0.20in)
    #rect(width: 3.4in, height: 1.6pt, fill: colors.nim)
    #v(0.20in)
    #text(size: 15pt, fill: colors.dim, tracking: 0.02em)[#byline]
  ]
  _footer(section: "opening")
  pagebreak()
}

#let section-slide(title, subtitle: none, section: none) = {
  _bg(section: section)
  align(horizon + left)[
    #pad(left: 0.90in, right: 1.20in)[
      #if section != none [
        #text(size: 10pt, fill: colors.cyan, weight: "semibold", tracking: 0.09em)[#upper(section)]
        #v(0.22in)
      ]
      #text(size: 56pt, fill: colors.text, weight: "bold")[#title]
      #if subtitle != none [
        #v(0.24in)
        #block(width: 11.0in)[#text(size: 24pt, fill: colors.muted)[#subtitle]]
      ]
    ]
  ]
  _footer(section: section)
  pagebreak()
}

#let lead(copy, sub: none) = [
  #text(size: 42pt, weight: "bold", fill: colors.text)[#copy]
  #if sub != none [
    #v(0.22in)
    #block(width: 11.2in)[#text(size: 20pt, fill: colors.muted)[#sub]]
  ]
]

#let small-bullets(items) = {
  set list(marker: ([#text(fill: colors.nim, size: 12pt)[-]],), spacing: 0.12in)
  text(size: 17.5pt, fill: colors.text)[#list(..items)]
}

#let micro(copy, fill: colors.dim) = text(size: 13pt, fill: fill)[#copy]

#let card(title: none, accent: colors.nim, body) = [
  #block(width: 100%)[
    #if title != none [
      #text(size: 11pt, weight: "semibold", fill: accent, tracking: 0.04em)[#upper(title)]
      #v(0.11in)
    ]
    #text(size: 17pt, fill: colors.text)[#body]
  ]
]

#let stat(label, value, accent: colors.nim) = [
  #rect(width: 100%, radius: 4pt, fill: colors.panel-2, stroke: 0.8pt + colors.line, inset: 15pt)[
    #text(size: 28pt, weight: "bold", fill: accent)[#value]
    #v(0.04in)
    #text(size: 13pt, fill: colors.muted)[#label]
  ]
]

#let callout(label, body, accent: colors.cyan) = [
  #block(
    width: 100%,
    inset: (left: 16pt, right: 0pt, top: 4pt, bottom: 4pt),
    stroke: (left: 2pt + accent),
  )[
    #text(size: 9.5pt, weight: "semibold", fill: accent, tracking: 0.08em)[#upper(label)]
    #v(0.08in)
    #text(size: 18pt)[#body]
  ]
]

#let code(size: 13.2pt, body) = [
  #rect(
    width: 100%,
    radius: 4pt,
    fill: colors.code-bg,
    stroke: 0.8pt + rgb("#313848"),
    inset: 14pt,
  )[
    #text(font: fonts.mono, size: size, fill: colors.text)[#body]
  ]
]

#let terminal(size: 14pt, body) = [
  #rect(
    width: 100%,
    radius: 4pt,
    fill: rgb("#080a0f"),
    stroke: 0.8pt + colors.line,
    inset: 14pt,
  )[
    #text(font: fonts.mono, size: size, fill: colors.green)[#body]
  ]
]

#let pill(copy, fill: colors.panel-2, stroke: colors.line, fg: colors.text) = [
  #box(
    inset: (x: 10pt, y: 5pt),
    radius: 5pt,
    fill: fill,
    stroke: 1pt + stroke,
  )[#text(size: 13pt, fill: fg, weight: "medium")[#copy]]
]

#let quote(copy, source: none) = [
  #rect(width: 100%, radius: 0pt, fill: none, inset: (left: 24pt, right: 0pt, top: 6pt, bottom: 6pt), stroke: (left: 2pt + colors.nim))[
    #text(size: 26pt, fill: colors.text)["#copy"]
    #if source != none [
      #v(0.18in)
      #text(size: 15pt, fill: colors.dim)[- #source]
    ]
  ]
]

#let image-card(path, width: 100%, pad: 12pt) = [
  #block(width: 100%, inset: pad)[
    #align(center)[#image(path, width: width)]
  ]
]

#let note(copy) = [
  #text(size: 13pt, fill: colors.dim)[#copy]
]

#let statement(copy, sub: none, accent: colors.nim) = [
  #block(width: 11.8in)[#text(size: 46pt, weight: "bold", fill: colors.text)[#copy]]
  #if sub != none [
    #v(0.24in)
    #block(width: 10.8in)[#text(size: 20pt, fill: colors.muted)[#sub]]
  ]
]

#let arrow(accent: colors.nim) = [
  #align(center + horizon)[
    #rect(width: 0.62in, height: 1.4pt, fill: accent)
  ]
]

#let graph-node(label, accent: colors.dim, active: false) = [
  #circle(
    radius: 0.32in,
    fill: if active { colors.nim } else { none },
    stroke: 1.1pt + accent,
  )[
    #align(center + horizon)[
      #text(size: 17pt, weight: "bold", fill: if active { colors.ink } else { colors.text })[#label]
    ]
  ]
]

#let graph-edge(accent: colors.dim) = [
  #align(center + horizon)[#rect(width: 0.92in, height: 1.2pt, fill: accent)]
]
