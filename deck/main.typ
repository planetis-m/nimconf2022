#import "styles/nimconf.typ": *

#set page(width: 16in, height: 9in, margin: 0pt, fill: colors.ink)
#set text(font: fonts.sans, fill: colors.text, size: 23pt)
#set par(leading: 0.72em)
#set heading(numbering: none)
#show link: set text(fill: colors.nim)
#show strong: set text(fill: colors.nim)
#show emph: set text(fill: colors.cyan)

#title-slide(
  "Fuzzing with drchaos",
  "Structured, coverage-guided fuzzing for Nim",
  "Antonis Geralis - NimConf 2022",
)[
]

#slide(title: "The talk in one sentence", kicker: "OPENING", section: "opening")[
  #statement(
    "Random bytes are useful. Random Nim values are often better.",
    sub: "drchaos lets libFuzzer explore typed data structures instead of making every target hand-parse a byte stream.",
  )
  #v(0.46in)
  #callout("The mood")[
    "I am Professor Chaos, bringer of destruction and mayhem." — Butters, with a tinfoil hat.
  ]
]

#slide(title: "What we will cover", kicker: "MAP", section: "opening")[
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.22in,
    card(title: "1. Fuzzing shape", accent: colors.cyan)[
      What a fuzzer needs, what it observes, and why coverage changes the game.
    ],
    card(title: "2. drchaos model", accent: colors.nim)[
      How a Nim type becomes the fuzz input, including post-processors and custom mutators.
    ],
    card(title: "3. Targets", accent: colors.green)[
      Tuples, variants, graphs, and the practical loop from crash to fix.
    ],
  )
  #v(0.42in)
  #note("We will stay practical: what to write, what to constrain, and what a useful crash looks like.")
]

#section-slide(
  "Why fuzz?",
  subtitle: "Because tests document what we remembered. Fuzzers explore what we forgot.",
  section: "fuzzing",
)

#slide(title: "A fuzzer is a feedback loop", kicker: "MODEL", section: "fuzzing")[
  #grid(columns: (1fr, 0.28fr, 1fr, 0.28fr, 1fr), gutter: 0.12in,
    card(title: "Generate", accent: colors.cyan)[
      Mutate an input corpus into new candidates.
    ],
    arrow(accent: colors.nim),
    card(title: "Run", accent: colors.nim)[
      Execute a small, deterministic target in-process.
    ],
    arrow(accent: colors.nim),
    card(title: "Learn", accent: colors.green)[
      Keep inputs that discover new coverage or crashes.
    ],
  )
  #v(0.45in)
  #quote(
    "The interesting part is not randomness. It is the loop between generated input, observed behavior, and future mutations.",
    source: "fuzzing without the fog machine",
  )
]

#slide(title: "What crashes count?", kicker: "SIGNALS", section: "fuzzing")[
  #grid(columns: (1fr, 1fr), gutter: 0.35in,
    [
      #card(title: "Hard failures", accent: colors.red)[
        #small-bullets((
          [crashes and panics],
          [failed assertions],
          [undefined behavior],
          [memory leaks and use-after-free],
        ))
      ]
      #v(0.22in)
      #card(title: "Semantic failures", accent: colors.nim)[
        #small-bullets((
          [roundtrip property broken],
          [container invariant violated],
          [parser accepts then cannot print],
          [API state becomes impossible],
        ))
      ]
    ],
    [
      #terminal[
```text
small target
fast execution
deterministic result
clear failure condition
```
      ]
      #v(0.24in)
      #callout("Rule of thumb", accent: colors.green)[
        If a target needs a network, a clock, or a meeting to explain, it is probably too large.
      ]
    ],
  )
]

#slide(title: "The byte-stream tax", kicker: "PROBLEM", section: "fuzzing")[
  #grid(columns: (1fr, 1fr), gutter: 0.42in,
    [
      #card(title: "Classic shape", accent: colors.dim)[
        #code(size: 12.5pt)[
```nim
proc LLVMFuzzerTestOneInput(
    data: ptr uint8;
    size: csize_t
): cint =
  let input = parse(data, size)
  exercise(input)
```
        ]
      ]
    ],
    [
      #card(title: "Where effort goes", accent: colors.red)[
        #small-bullets((
          [splitting bytes into fields],
          [building nested dynamic values],
          [keeping variants internally valid],
          [reaching deep comparisons],
        ))
      ]
      #v(0.18in)
      #callout("drchaos angle", accent: colors.nim)[
        Make the target type explicit, then mutate structured values directly.
      ]
    ],
  )
]

#section-slide(
  "Enter drchaos",
  subtitle: "LibFuzzer plus sanitizers, with a Nim-aware structured mutator in the middle.",
  section: "drchaos",
)

#slide(title: "What is drchaos?", kicker: "STACK", section: "drchaos")[
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.22in,
    card(title: "LLVM libFuzzer", accent: colors.cyan)[
      The engine: coverage, corpus, mutation scheduling, crash minimization.
    ],
    card(title: "Sanitizers", accent: colors.red)[
      The tripwires: AddressSanitizer and UndefinedBehaviorSanitizer.
    ],
    card(title: "Nim mutators", accent: colors.nim)[
      The translator: bytes become strings, tuples, objects, enums, refs, arrays, sets, and seqs.
    ],
  )
  #v(0.34in)
  #image-card(assets.stack, width: 66%, pad: 10pt)
]

#slide(title: "The API surface is tiny", kicker: "API", section: "drchaos")[
  #grid(columns: (1.08fr, 0.92fr), gutter: 0.36in,
    [
      #code(size: 13pt)[
```nim
import drchaos

func fuzzTarget(data: MyInput) =
  # Use data. Check invariants.
  # Do not mutate data.

defaultMutator(fuzzTarget)
```
      ]
    ],
    [
      #card(title: "The target signature is the schema", accent: colors.nim)[
        #small-bullets((
          [`MyInput` drives serialization],
          [equality support affects several generated types],
          [`default` can define valid refs],
          [`postProcess` repairs dependencies],
        ))
      ]
      #v(0.2in)
      #callout("Nim identity", accent: colors.cyan)[
        The target stays ordinary Nim. The strange part lives in the mutator framework.
      ]
    ],
  )
]

#slide(title: "A deliberately simple target", kicker: "TUPLE", section: "targets")[
  #grid(columns: (1.1fr, 0.9fr), gutter: 0.32in,
    [
      #code(size: 12.5pt)[
```nim
import drchaos

proc fuzzMe(s: string, a, b, c: int32) =
  if a == 0xdeadc0de'i32 and
      b == 0x11111111'i32 and
      c == 0x22222222'i32:
    if s.len == 100:
      doAssert false

func fuzzTarget(data: (string, int32, int32, int32)) =
  let (s, a, b, c) = data
  fuzzMe(s, a, b, c)

defaultMutator(fuzzTarget)
```
      ]
    ],
    [
      #card(title: "Why this works", accent: colors.green)[
        The tuple gives the fuzzer handles for each field. Value profiling helps it cross exact comparisons.
      ]
      #v(0.22in)
      #card(title: "Why this is only a warm-up", accent: colors.red)[
        The payoff arrives when input is nested, variant-heavy, or graph-shaped.
      ]
    ],
  )
]

#slide(title: "Structured inputs change the target", kicker: "SHIFT", section: "drchaos")[
  #grid(columns: (1fr, 0.26fr, 1fr), gutter: 0.18in,
    card(title: "Before", accent: colors.dim)[
      Parse arbitrary bytes, reject most cases, then maybe reach the API.
    ],
    arrow(accent: colors.nim),
    card(title: "After", accent: colors.nim)[
      Generate values that resemble the domain, then spend cycles on behavior.
    ],
  )
  #v(0.42in)
  #grid(columns: (1fr, 1fr, 1fr, 1fr), gutter: 0.16in,
    card(title: "Enums", accent: colors.cyan)[finite choices],
    card(title: "Variants", accent: colors.green)[shape follows tag],
    card(title: "Seqs", accent: colors.nim)[bounded growth],
    card(title: "Refs", accent: colors.red)[defaults avoid nil traps],
  )
]

#slide(title: "Post-processors keep relations valid", kicker: "VALIDITY", section: "drchaos")[
  #grid(columns: (1.05fr, 0.95fr), gutter: 0.34in,
    [
      #code(size: 12.5pt)[
```nim
proc postProcess[T](x: var seq[Node[T]]; r: var Rand) =
  for n in x.mitems:
    for i in countdown(n.edges.high, 0):
      if n.edges[i].int >= x.len:
        del(n.edges, i)
```
      ]
    ],
    [
      #card(title: "What it says", accent: colors.nim)[
        Edges may only point to nodes that exist.
      ]
      #v(0.18in)
      #card(title: "Why not encode everything in mutate?", accent: colors.cyan)[
        Mutators explore. Post-processors restore cross-field invariants visibly.
      ]
    ],
  )
]

#section-slide(
  "Graph target",
  subtitle: "The demo target is a small graph library: nodes, edges, BFS, and invariants.",
  section: "targets",
)

#slide(title: "The graph gives chaos some topology", kicker: "DEMO", section: "targets")[
  #grid(columns: (0.86fr, 1.14fr), gutter: 0.40in,
    [
      #card(title: "Domain", accent: colors.cyan)[
        #small-bullets((
          [graph as adjacency list],
          [node indices as a distinct type],
          [bounded node and edge counts],
          [BFS as observable behavior],
        ))
      ]
      #v(0.22in)
      #callout("Target invariant", accent: colors.green)[
        Traversal should not crash, and every visited node should be reachable from the source.
      ]
    ],
    [
      #v(0.42in)
      #align(center)[
        #grid(columns: (auto, auto, auto, auto, auto), rows: (0.86in, 0.76in, 0.86in), gutter: 0.02in,
          graph-node("0", accent: colors.nim-2, active: true),
          graph-edge(accent: colors.nim),
          graph-node("1", accent: colors.cyan),
          graph-edge(accent: colors.dim),
          graph-node("4", accent: colors.cyan),
          [],
          [],
          graph-edge(accent: colors.green),
          [],
          [],
          [],
          [],
          graph-node("2", accent: colors.green),
          graph-edge(accent: colors.red),
          graph-node("3", accent: colors.red),
        )
      ]
      #v(0.40in)
      #align(center)[
        #text(size: 15pt, fill: colors.muted)[A small adjacency list is enough: structure first, behavior second.]
      ]
    ],
  )
]

#slide(title: "Constrain the search space", kicker: "MUTATORS", section: "targets")[
  #grid(columns: (1.08fr, 0.92fr), gutter: 0.34in,
    [
      #code(size: 12.2pt)[
```nim
const
  MaxNodes = 8
  MaxEdges = 2

proc mutate(
    value: var NodeIdx;
    sizeIncreaseHint: int;
    enforceChanges: bool;
    r: var Rand
) =
  repeatMutate(mutateEnum(value.int, MaxNodes, r).NodeIdx)
```
      ]
    ],
    [
      #card(title: "This is not cheating", accent: colors.nim)[
        Bounds make the state space productive. The fuzzer still explores combinations; it stops inventing node 90 in a graph with 3 nodes.
      ]
      #v(0.2in)
      #card(title: "Use distinct types", accent: colors.cyan)[
        A distinct `NodeIdx` gets a domain-specific mutator without changing the production representation outside fuzz builds.
      ]
    ],
  )
]

#slide(title: "Target shape for BFS", kicker: "INVARIANTS", section: "targets")[
  #grid(columns: (1fr, 1fr), gutter: 0.32in,
    [
      #code(size: 12.5pt)[
```nim
func fuzzTarget(x: Graph[int8]) =
  when defined(dumpFuzzInput):
    debugEcho(x)

  if x.len > 0:
    discard x.breadthFirstSearch(source = 0.NodeIdx)
```
      ]
    ],
    [
      #card(title: "Start small", accent: colors.green)[
        A crash-only target is still valuable when the generated input has realistic shape.
      ]
      #v(0.2in)
      #card(title: "Then add properties", accent: colors.nim)[
        Remove an edge, preserve node count. Traverse from a source, ensure each result is reachable.
      ]
    ],
  )
]

#slide(title: "The compile line is part of the tool", kicker: "CONFIG", section: "practice")[
  #terminal(size: 11.8pt)[
```text
--cc:clang
-d:useMalloc
-t:"-fsanitize=fuzzer,address,undefined"
-l:"-fsanitize=fuzzer,address,undefined"
-d:nosignalhandler
--nomain:on
--mm:arc
-g
```
  ]
  #v(0.28in)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.18in,
    card(title: "clang", accent: colors.cyan)[libFuzzer integration],
    card(title: "sanitizers", accent: colors.red)[memory and UB visibility],
    card(title: "ARC/ORC", accent: colors.nim)[better fit for variants and modern Nim],
  )
]

#slide(title: "Crash workflow", kicker: "PRACTICE", section: "practice")[
  #grid(columns: (1fr, 0.26fr, 1fr, 0.26fr, 1fr), gutter: 0.1in,
    card(title: "Find", accent: colors.red)[Run fast with sanitizers and a minimal target.],
    arrow(accent: colors.nim),
    card(title: "Reproduce", accent: colors.cyan)[Recompile with debug info; pass the crash artifact back in.],
    arrow(accent: colors.nim),
    card(title: "Explain", accent: colors.green)[Turn the crash into a regression test or a narrower invariant.],
  )
  #v(0.42in)
  #callout("Practical note", accent: colors.nim)[
    Use `debugEcho(x)` behind a flag when you need the generated Nim value. Keep hot fuzz loops quiet.
  ]
]

#slide(title: "What makes a good target?", kicker: "CHECKLIST", section: "practice")[
  #grid(columns: (1fr, 1fr), gutter: 0.36in,
    card(title: "Do", accent: colors.green)[
      #small-bullets((
        [keep it deterministic],
        [keep it fast enough for millions of runs],
        [check a clear property],
        [prefer small, typed inputs],
        [bound uninteresting growth],
      ))
    ],
    card(title: "Avoid", accent: colors.red)[
      #small-bullets((
        [printing every case],
        [mutating the input value in the target],
        [depending on external services],
        [swallowing crashes into generic errors],
        [testing five subsystems at once],
      ))
    ],
  )
]

#slide(title: "Where drchaos is sharpest", kicker: "FIT", section: "practice")[
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.2in,
    card(title: "Parsers and printers", accent: colors.cyan)[
      Roundtrip properties, AST variants, escaping rules, boundary values.
    ],
    card(title: "Containers", accent: colors.nim)[
      Insert/delete invariants, iterator safety, edge cases around empty data.
    ],
    card(title: "Stateful APIs", accent: colors.green)[
      Command sequences, model checks, generated histories, offline simulations.
    ],
  )
  #v(0.34in)
  #quote(
    "The fuzzer is not a proof. It is a persistent reviewer with unusual taste in inputs.",
  )
]

#slide(title: "Known limits", kicker: "BOUNDARIES", section: "practice")[
  #grid(columns: (1fr, 1fr), gutter: 0.34in,
    card(title: "Currently awkward", accent: colors.red)[
      #small-bullets((
        [polymorphic serialization],
        [reference cycles],
        [raw pointers without user serializers],
        [object variants outside modern memory management],
      ))
    ],
    card(title: "Design response", accent: colors.nim)[
      #small-bullets((
        [wrap raw pieces with explicit serializers],
        [define `default` for non-nil refs],
        [use distinct types to narrow fields],
        [keep generated structure honest with `postProcess`],
      ))
    ],
  )
]

#section-slide(
  "Future directions",
  subtitle: "Richer mutators, stateful APIs, and model-heavy simulation work.",
  section: "future",
)

#slide(title: "Future directions", kicker: "NEXT", section: "future")[
  #statement(
    "The next step is less random noise, more domain signal.",
    sub: "Richer mutator architecture, generated command streams, and offline simulation work all push the same direction: make exploration resemble the system under test.",
    accent: colors.green,
  )
]

#closing-slide(title: none, kicker: "CLOSE", section: "close")[
  #v(1.20in)
  #statement(
    "Questions?",
    sub: "Preferably the kind that produce smaller reproducers.",
    accent: colors.nim,
  )
  #v(1.10in)
  #grid(columns: (1.15fr, 0.85fr), gutter: 0.55in,
    [
      #text(size: 11pt, fill: colors.nim, weight: "semibold", tracking: 0.08em)[PROJECT SUPPORT]
      #v(0.14in)
      #text(size: 17pt, fill: colors.muted)[zah and Status funded drchaos. disruptek sponsored the work. Nim community testing made the rough edges visible.]
    ],
    [
      #text(size: 11pt, fill: colors.cyan, weight: "semibold", tracking: 0.08em)[THANK YOU]
      #v(0.14in)
      #text(size: 17pt, fill: colors.muted)[Antonis Geralis - NimConf 2022]
    ],
  )
]
