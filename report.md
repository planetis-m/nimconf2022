# Fuzzing with drchaos — Talk Report

## Narrative Arc

The talk follows a four-act structure: **Why fuzz?** (motivation), **Enter drchaos** (the tool), **Targets in practice** (application), and **Future directions** (horizon). Each act builds on the previous, moving from abstract fuzzing concepts through a concrete Nim tool to real-world targets and limitations.

---

## Act 1: Opening

### Slide: Title Slide

**Purpose:** Establish speaker, topic, and conference context.

Speaker is Antonis Geralis, presenting at NimConf 2022. Title: "Fuzzing with drchaos." Subtlety: "Structured, coverage-guided fuzzing for Nim" — the word "structured" is the entire thesis. The logo (crown) and conference branding ground the presentation visually. The terminal aesthetic (dark background, gold/yellow accent, cyan secondary) signals a technical, no-fluff talk.

---

### Slide: The Talk in One Sentence (OPENING)

**Purpose:** Give the audience the core idea immediately, no suspense.

"Random bytes are useful. Random Nim values are often better." — This is the thesis statement. LibFuzzer is powerful, but forcing every target to parse raw byte streams is wasteful. drchaos translates bytes into typed Nim values, letting the fuzzer explore structured data directly.

The "mood" callout: "We still invite chaos. We just give it a type signature and a smaller room to trash." — Sets the tone: controlled chaos, not blind randomness.

---

### Slide: What We Will Cover (MAP)

**Purpose:** Roadmap so the audience knows what to expect. Three pillars:

1. **Fuzzing shape** — What a fuzzer needs (generate, run, learn), what coverage-guided means, and why coverage changes the game from random testing to systematic exploration.
2. **drchaos model** — How Nim types become fuzz inputs. The target signature IS the schema. Post-processors repair inter-field invariants. Custom mutators narrow the search space.
3. **Targets** — Tuples, variants, graphs. Practical loop from crash discovery to fix. Real demo code.

Bottom note: "We will stay practical: what to write, what to constrain, and what a useful crash looks like." — Promises actionable content.

---

## Act 2: Why Fuzz?

### Section Slide: Why Fuzz?

"Because tests document what we remembered. Fuzzers explore what we forgot." — The emotional core of the talk. Tests are author-biased. Fuzzers have no preconceptions. This is the value proposition.

---

### Slide: A Fuzzer Is a Feedback Loop (MODEL)

**Purpose:** Demystify fuzzing. It's not magic randomness — it's a three-step feedback loop:

1. **Generate** — Mutate an input corpus into new candidates.
2. **Run** — Execute a small, deterministic target in-process (fast, no network).
3. **Learn** — Keep inputs that discover new coverage or trigger crashes.

The quote: "The interesting part is not randomness. It is the loop between generated input, observed behavior, and future mutations." — Attacks the common misconception that fuzzing is just throwing random data at a program.

---

### Slide: What Crashes Count? (SIGNALS)

**Purpose:** Define what "failure" means in fuzzing. Two categories:

**Hard failures** — crashes, panics, failed assertions, undefined behavior, memory leaks, use-after-free. The sanitizers catch these.

**Semantic failures** — roundtrip property broken, container invariant violated, parser accepts then cannot print, API state becomes impossible. These are logic bugs that don't crash but produce wrong answers.

The terminal sidebar lists target qualities: small, fast, deterministic, clear failure condition. The "rule of thumb": "If a target needs a network, a clock, or a meeting to explain, it is probably too large." — Practical boundary-setting.

---

### Slide: The Byte-Stream Tax (PROBLEM)

**Purpose:** Name the pain point drchaos solves. Classic LibFuzzer target shape:

```nim
proc LLVMFuzzerTestOneInput(data: ptr uint8; size: csize_t): cint =
  let input = parse(data, size)
  exercise(input)
```

The target author must split bytes into fields, build nested dynamic values, keep variants internally valid, and help the fuzzer reach deep comparisons — all by hand. This is effort wasted on plumbing instead of behavior testing.

**drchaos angle:** Make the target type explicit, then mutate structured values directly. The type IS the schema. No parsing step.

---

## Act 3: Enter drchaos

### Section Slide: Enter drchaos

"LibFuzzer plus sanitizers, with a Nim-aware structured mutator in the middle." — The tool's position in the stack.

---

### Slide: What Is drchaos? (STACK)

**Purpose:** Three-layer architecture:

1. **LLVM libFuzzer** — The engine: coverage instrumentation, corpus management, mutation scheduling, crash minimization. Battle-tested, from the LLVM project.
2. **Sanitizers** — The tripwires: AddressSanitizer (memory errors: buffer overflow, use-after-free, leaks) and UndefinedBehaviorSanitizer (integer overflow, null dereference, type punning violations).
3. **Nim mutators** — The translator: bytes become strings, tuples, objects, enums, refs, arrays, sets, and seqs. Each Nim type gets a domain-aware mutator that respects structure.

The stack diagram (`what_is.png`) visualizes the three layers. This is the architecture slide — show the audience how the pieces fit.

---

### Slide: The API Surface Is Tiny (API)

**Purpose:** Show how little code the user writes:

```nim
import drchaos

func fuzzTarget(data: MyInput) =
  # Use data. Check invariants.
  # Do not mutate data.

defaultMutator(fuzzTarget)
```

Four things to note:

- **`MyInput` drives serialization** — The type signature determines what gets generated and mutated.
- **Equality support affects generated types** — Types without `==` get different treatment.
- **`default` can define valid refs** — Avoids nil reference traps by providing sensible defaults.
- **`postProcess` repairs dependencies** — Cross-field invariants fixed after mutation.

**Nim identity callout:** "The target stays ordinary Nim. The strange part lives in the mutator framework." — Reassuring: you're writing normal Nim, not framework code.

---

### Slide: Structured Inputs Change the Target (SHIFT)

**Purpose:** Before/after contrast. Classic fuzzing: parse arbitrary bytes, reject most cases, maybe reach the API. drchaos fuzzing: generate values that resemble the domain, then spend cycles on behavior. The fuzzer stops wasting time on structurally invalid inputs.

Four type categories that benefit:

- **Enums** — Finite choices, no out-of-range nonsense.
- **Variants** — Shape follows the tag; impossible states become unrepresentable.
- **Seqs** — Bounded growth, not unbounded allocation.
- **Refs** — Defaults avoid nil traps; valid object graphs from the start.

---

### Slide: Post-Processors Keep Relations Valid (VALIDITY)

**Purpose:** Explain the post-processor pattern. Mutators explore freely — they may create edges pointing to nodes that don't exist. Post-processors restore cross-field invariants after mutation:

```nim
proc postProcess[T](x: var seq[Node[T]]; r: var Rand) =
  for n in x.mitems:
    for i in countdown(n.edges.high, 0):
      if n.edges[i].int >= x.len:
        del(n.edges, i)
```

**What it says:** Edges may only point to nodes that exist. After mutation, edges referencing deleted or out-of-bounds nodes are pruned.

**Why not encode everything in mutate?** Mutators explore. Post-processors restore. Separation of concerns: mutation is creative, post-processing is corrective.

---

## Act 4: Targets

### Section Slide: Graph Target

"The demo target is a small graph library: nodes, edges, BFS, and invariants." — Transition into the practical demo section.

---

### Slide: The Graph Gives Chaos Some Topology (DEMO)

**Purpose:** Introduce the demo domain. The graph target is an adjacency list representation with:

- Node indices as a distinct type (`NodeIdx = distinct int`)
- Bounded node count (MaxNodes = 8)
- Bounded edge count (MaxEdges = 2)
- BFS as observable behavior

**Target invariant:** "Traversal should not crash, and every visited node should be reachable from the source."

The visual shows a small adjacency list graph with nodes 0-4 and edges between them, demonstrating that even a tiny graph has enough structure to be interesting.

---

### Slide: Constrain the Search Space (MUTATORS)

**Purpose:** Show the custom mutator for `NodeIdx`:

```nim
const MaxNodes = 8
const MaxEdges = 2

proc mutate(value: var NodeIdx; sizeIncreaseHint: int;
            enforceChanges: bool; r: var Rand) =
  repeatMutate(mutateEnum(value.int, MaxNodes, r).NodeIdx)
```

**This is not cheating:** Bounds make the state space productive. The fuzzer still explores all combinations of nodes and edges — it just stops inventing node index 90 in a graph with 3 nodes. Without bounds, most generated inputs would be structurally invalid.

**Use distinct types:** A distinct `NodeIdx` gets a domain-specific mutator without changing the production representation outside fuzz builds. The distinct type is the hook point.

---

### Slide: Target Shape for BFS (INVARIANTS)

**Purpose:** Show the fuzz target for BFS:

```nim
func fuzzTarget(x: Graph[int8]) =
  when defined(dumpFuzzInput): debugEcho(x)
  if x.len > 0:
    discard x.breadthFirstSearch(source = 0.NodeIdx)
```

**Start small:** A crash-only target (just run BFS, assert nothing except no crashes) is still valuable when the generated input has realistic shape. The fuzzer explores valid-looking graphs, not random byte soups.

**Then add properties:** Remove an edge, preserve node count. Traverse from a source, ensure each result is reachable. Add assertions incrementally.

---

### Slide: The Compile Line Is Part of the Tool (CONFIG)

**Purpose:** Show the full compiler invocation. This is not hidden magic — it's explicit flags:

```
--cc:clang
-d:useMalloc
-t:"-fsanitize=fuzzer,address,undefined"
-l:"-fsanitize=fuzzer,address,undefined"
-d:nosignalhandler
--nomain:on
--mm:arc
-g
```

Three pillars explained:
- **clang** — Required for libFuzzer integration (GCC doesn't support `-fsanitize=fuzzer`).
- **sanitizers** — AddressSanitizer for memory errors, UBSan for undefined behavior. Both are compile-time instrumentations with runtime checks.
- **ARC/ORC** — Better fit for variants and modern Nim. Reference counting plays well with the mutation model.

---

### Slide: Crash Workflow (PRACTICE)

**Purpose:** Three-step workflow:

1. **Find** — Run fast with sanitizers and a minimal target. Let the fuzzer run for hours or days. It saves crashing inputs automatically.
2. **Reproduce** — Recompile with debug info, pass the crash artifact back in. Single-step through the crash in GDB or LLDB.
3. **Explain** — Turn the crash into a regression test or a narrower invariant. The crash artifact IS the reproducer.

**Practical note:** Use `debugEcho(x)` behind a compile flag when you need to see the generated Nim value. Keep hot fuzz loops quiet — printing every case kills throughput.

---

### Slide: What Makes a Good Target? (CHECKLIST)

**Purpose:** Actionable guidance. Do vs. Avoid.

**Do:**
- Keep it deterministic (same input → same behavior)
- Keep it fast enough for millions of runs
- Check a clear property (not "works correctly" — "BFS never crashes" or "visited set ⊆ reachable set")
- Prefer small, typed inputs (tuples, not giant config objects)
- Bound uninteresting growth (MaxNodes, MaxEdges)

**Avoid:**
- Printing every case (kills performance)
- Mutating the input value in the target (the mutator owns mutation)
- Depending on external services (network, filesystem, clock)
- Swallowing crashes into generic errors (sanitizers need actual crashes/asserts)
- Testing five subsystems at once (one target, one property)

---

### Slide: Where drchaos Is Sharpest (FIT)

**Purpose:** Best-fit domains:

1. **Parsers and printers** — Roundtrip properties (parse then print, compare), AST variants, escaping rules, boundary values (empty, max-length, null bytes).
2. **Containers** — Insert/delete invariants, iterator safety during modification, edge cases around empty data.
3. **Stateful APIs** — Command sequences (open, write, read, close), model checks against a reference implementation, generated operation histories, offline simulations.

**Closing quote:** "The fuzzer is not a proof. It is a persistent reviewer with unusual taste in inputs." — Honest about limitations. Fuzzing finds bugs; it doesn't prove absence of bugs.

---

### Slide: Known Limits (BOUNDARIES)

**Purpose:** Transparency about what drchaos struggles with:

**Currently awkward:**
- Polymorphic serialization (type erasure complicates mutation)
- Reference cycles (can cause infinite loops in serialization)
- Raw pointers without user serializers (no automated mutation for `ptr`)
- Object variants outside modern memory management (ARC/ORC required)

**Design responses:**
- Wrap raw pieces with explicit serializers
- Define `default` for non-nil refs (give the mutator a valid starting point)
- Use distinct types to narrow fields (give the mutator domain knowledge)
- Keep generated structure honest with `postProcess`

---

## Act 5: Future & Close

### Section Slide: Future Directions

"Richer mutators, stateful APIs, and model-heavy simulation work." — The horizon.

---

### Slide: Future Directions (NEXT)

**Purpose:** One statement slide. "The next step is less random noise, more domain signal." — The thesis for future work. Sub: "Richer mutator architecture, generated command streams, and offline simulation work all push the same direction: make exploration resemble the system under test."

This is aspirational but grounded — every item mentioned connects to the demo shown.

---

### Slide: Closing (CLOSE)

**Purpose:** End with energy. Two statements: "Questions? Preferably the kind that produce smaller reproducers." — Witty callback to the crash workflow.

Credits: zah and Status funded drchaos. disruptek sponsored the work. Nim community testing made the rough edges visible.

Speaker: Antonis Geralis, NimConf 2022.
