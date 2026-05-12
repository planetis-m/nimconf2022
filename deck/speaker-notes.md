# Speaker Notes — Fuzzing with drchaos

> NimConf 2022 · Antonis Geralis
> Optimized for live delivery · Read vertically, not linearly

---

## 1. TITLE SLIDE

**NIMCONF 2022 · "Fuzzing with drchaos" · Crown logo right**

---

Core message: structured fuzzing is **here** for Nim — and it looks like normal Nim code.

Pause.

Let the title breathe. Crown logo anchors the eye.

Then: "Structured, coverage-guided fuzzing for Nim."

---

*Rhythm:*

I'm Antonis. @planetis on GitHub.

This talk is about **drchaos**.

It's a fuzzing framework. It sits on top of libFuzzer.

But the interesting part is what happens **between** the bytes and your code.

---

*Visual anchors:*
- Glance at title text to reset
- Crown logo top-right is the home point
- Bottom-right: OPENING / page 1

---

*Transition:*

Let me tell you the whole talk in one sentence.

---

## 2. THE TALK IN ONE SENTENCE
### OPENING · Statement layout + callout box

---

Core message: random bytes are useful — random Nim **values** are better.

*Delivery:*

Read the statement slowly. Let it land.

**Pause.**

Subtitle reinforces: drchaos lets libFuzzer explore typed data structures — instead of making every target hand-parse a byte stream.

That's the whole pitch.

---

*Emphasis:*

Random bytes are **useful**.

Random Nim values are often **better**.

---

*Visual anchors:*
- Statement text (46pt, bold, white)
- Subtitle in muted below
- Callout box bottom-left: "THE MOOD"
- Gold left-border on the callout

---

*Mood beat:*

"We still invite chaos."

"We just give it a **type** signature."

Smile. That's the whole talk in three words. Controlled chaos, not anarchy.

---

*Transition:*

Here's what we're going to cover.

---

## 3. WHAT WE WILL COVER
### MAP · Three card grid + note

---

Core message: three **pillars** — shape, model, targets.

---

*Rhythm:*

Walk left to right across the cards.

**One.** Fuzzing shape.

What a fuzzer needs. What it observes. Why coverage changes the game.

**Two.** drchaos model.

How a Nim type becomes the fuzz input. Post-processors. Custom mutators.

**Three.** Targets.

Tuples. Variants. Graphs. The full loop — crash to fix.

---

*Emphasis:*

Coverage changes the **game**.

The target signature **is** the schema.

---

*Visual anchors:*
- Three cards in a row: cyan → gold → green
- Each card has an uppercase title in its accent color
- Bottom muted note: "We will stay practical"

---

*Anchor note:*

Bottom text — "what to write, what to constrain, what a useful crash looks like."

Point at it. That's our promise.

---

*Transition:*

Let's start with the **why**.

---

## 4. SECTION — WHY FUZZ?

**Large centered title · Subtitle below**

---

Core message: tests document what we **remembered** — fuzzers explore what we forgot.

---

*Delivery:*

Read the title. Let the screen sit.

Then the subtitle. Slow.

"Because tests document what we remembered."

"Fuzzers explore what we **forgot**."

---

*Beat:*

That's the whole emotional argument.

Tests are author-biased. You test what you thought of.

Fuzzers have no preconceptions. They find what you didn't think of.

---

*Visual anchors:*
- Large centered title: "Why fuzz?" (56pt, white, bold)
- Subtitle in muted below (24pt)
- Section label top-left: FUZZING
- Page number bottom-right

---

*Transition:*

So — what actually **is** a fuzzer?

---

## 5. A FUZZER IS A FEEDBACK LOOP
### MODEL · Three cards with arrows + quote

---

Core message: it's not **randomness** — it's a feedback loop.

---

*Rhythm:*

Three steps. Walk the arrows.

**Generate.** Mutate an input corpus into new candidates.

**Run.** Execute a small, deterministic target in-process.

**Learn.** Keep inputs that discover new coverage — or crashes.

That's it. That's the whole machine.

---

*Emphasis:*

The **loop** is the interesting part.

---

*Visual anchors:*
- Three cards: cyan → gold → green
- Arrows between them (gold horizontal bars)
- Quote below with gold left-border

---

*Anchor quote:*

Point at the quote. "The interesting part is not randomness."

"It is the loop between generated input, observed behavior, and future mutations."

Read it. Don't rush it.

---

*Transition:*

But what actually counts as a crash?

---

## 6. WHAT CRASHES COUNT?
### SIGNALS · Two-column grid + terminal sidebar

---

Core message: crashes aren't just **segfaults** — semantic failures count too.

---

*Rhythm:*

Two columns. Start left.

**Hard failures.** Crashes, panics, failed assertions.

Undefined behavior. Memory leaks. Use-after-free.

These are what sanitizers catch.

**Semantic failures.** Roundtrip property broken.

Container invariant violated. Parser accepts — then cannot print.

API state becomes impossible.

These don't crash. They produce **wrong** answers. Fuzzers can catch both.

---

*Emphasis:*

**Hard** failures — left column, red title.

**Semantic** failures — right column, gold title.

---

*Visual anchors:*
- Left: red card + gold card stacked
- Right: terminal block with green text, then callout box
- Terminal lists target qualities

---

*Anchor terminal:*

Glance at terminal corner. "small target, fast execution, deterministic result, clear failure condition."

Point: these are your constraints.

---

*Callout beat:*

"If a target needs a network, a clock, or a **meeting** to explain — it's probably too large."

Smile. Pause for the laugh.

---

*Transition:*

Now here's the problem that drchaos solves.

---

## 7. THE BYTE-STREAM TAX
### PROBLEM · Code left + bullet list right + callout

---

Core message: classic fuzzing wastes **effort** on parsing — drchaos skips that step.

---

*Rhythm:*

Left column. The classic shape.

`LLVMFuzzerTestOneInput` — raw bytes, raw size.

You parse. You exercise.

Everyone does this. Everyone writes the same parser.

---

*Emphasis:*

Where does the effort **go**?

---

*Bullets:*

Walk the right column:

Splitting bytes into fields.

Building nested dynamic values.

Keeping variants internally valid.

Reaching deep comparisons.

All of this is **plumbing**. It's not testing your logic.

---

*Visual anchors:*
- Left: code block in dark panel
- Right: red card "Where effort goes" + cyan callout "drchaos angle"
- Gold callout with left-border accent

---

*Anchor callout:*

"Make the target type explicit — then mutate structured values directly."

That's the solution. The type **is** the schema. No parsing. No hand-written deserializer.

---

*Transition:*

So let me introduce the tool.

---

## 8. SECTION — ENTER DRCHAOS

**Large centered title · Subtitle below**

---

Core message: libFuzzer + sanitizers — with a Nim-aware **mutator** in the middle.

---

*Delivery:*

Read the title.

Then the subtitle.

"LibFuzzer plus sanitizers."

"With a Nim-aware structured mutator in the middle."

That's the stack. Three layers. Let's look at each.

---

*Visual anchors:*
- Large centered title: "Enter drchaos"
- Subtitle in muted
- Section label: DRCHAOS

---

*Transition:*

Here's what drchaos actually **is**.

---

## 9. WHAT IS DRCHAOS?
### STACK · Three cards + architecture diagram

---

Core message: three **layers** — engine, tripwires, translator.

---

*Rhythm:*

Three cards. Left to right.

**LLVM libFuzzer.** The engine.

Coverage instrumentation. Corpus management. Mutation scheduling. Crash minimization.

Battle-tested. From the LLVM project.

**Sanitizers.** The tripwires.

AddressSanitizer — memory errors. UBSan — undefined behavior.

They make bugs **visible**. They turn silent corruption into loud crashes.

**Nim mutators.** The translator.

Bytes become strings. Tuples. Objects. Enums. Refs. Arrays. Sets. Seqs.

Each Nim type gets a domain-aware mutator.

---

*Emphasis:*

The **translator** is where drchaos lives.

---

*Visual anchors:*
- Three cards: cyan → red → gold
- Architecture diagram below (what_is.png)
- Diagram shows the three-layer stack

---

*Anchor diagram:*

Point at the stack diagram. "This is the architecture."

Trace bottom to top: libFuzzer → sanitizers → Nim mutators.

Bytes enter at the bottom. Typed Nim values come out at the top.

---

*Transition:*

And here's what you actually write.

---

## 10. THE API SURFACE IS TINY
### API · Code left + bullet card right + callout

---

Core message: import drchaos, write a target, call `defaultMutator` — **done**.

---

*Rhythm:*

Left column. Look at the code.

```nim
import drchaos

func fuzzTarget(data: MyInput) =
  # Use data. Check invariants.

defaultMutator(fuzzTarget)
```

That's the whole API. Two calls.

---

*Emphasis:*

**Tiny** — that's intentional.

---

*Bullets:*

Right column. Four things to notice:

`MyInput` drives serialization. The type signature is the schema.

Equality support affects generated types. If your type has `==`, that matters.

`default` can define valid refs. No nil traps.

`postProcess` repairs cross-field dependencies. We'll show this.

---

*Visual anchors:*
- Left: code block in dark panel
- Right: gold card "The target signature is the schema" + cyan callout
- Bullet list in right card

---

*Anchor callout:*

"The target stays ordinary Nim."

"The strange part lives in the mutator framework."

Reassure the audience. You're not writing framework code.

---

*Transition:*

Let me show you a warm-up target.

---

## 11. A DELIBERATELY SIMPLE TARGET
### TUPLE · Code left + two cards right

---

Core message: a **tuple** gives the fuzzer handles for each field.

---

*Rhythm:*

Left column. Walk the code.

`fuzzMe` — takes string, three int32s.

Three exact comparisons: `0xdeadc0de`, `0x11111111`, `0x22222222`.

Plus string length == 100.

That's five constraints. In a random byte stream, good luck.

But the tuple gives the fuzzer **handles**. One per field.

---

*Emphasis:*

The tuple **gives** handles.

---

*Visual anchors:*
- Left: code block with `fuzzMe` and `fuzzTarget`
- Right-top: green card "Why this works"
- Right-bottom: red card "Why this is only a warm-up"

---

*Anchor cards:*

Green card: value profiling helps cross exact comparisons. libFuzzer learns magic constants.

Red card: the payoff arrives when input is nested, variant-heavy, or graph-shaped.

This is the teaser.

---

*Transition:*

So what changes when you fuzz with **structure**?

---

## 12. STRUCTURED INPUTS CHANGE THE TARGET
### SHIFT · Before/After arrow + four type cards

---

Core message: you spend cycles on **behavior** — not on rejecting invalid inputs.

---

*Rhythm:*

Before/after arrow. Top of slide.

**Before:** Parse arbitrary bytes, reject most cases, maybe reach the API.

**After:** Generate values that resemble the domain, then spend cycles on behavior.

The fuzzer stops wasting time on structurally **impossible** inputs.

---

*Emphasis:*

**Behavior** — not validation.

---

*Type cards:*

Four type categories. Walk them.

**Enums** — finite choices. No out-of-range nonsense.

**Variants** — shape follows the tag. Impossible states become unrepresentable.

**Seqs** — bounded growth. Not unbounded allocation.

**Refs** — defaults avoid nil traps. Valid object graphs from the start.

---

*Visual anchors:*
- Top: Before (dim card) → arrow (gold) → After (gold card)
- Bottom: four cards in row — cyan, green, gold, red

---

*Anchor cards:*

Point at each card as you name the type. One beat per card.

---

*Transition:*

But there's still a problem: cross-field invariants.

---

## 13. POST-PROCESSORS KEEP RELATIONS VALID
### VALIDITY · Code left + two cards right

---

Core message: mutators **explore** — post-processors **repair**.

---

*Rhythm:*

Left column. The code.

```nim
proc postProcess[T](x: var seq[Node[T]]; r: var Rand) =
  for n in x.mitems:
    for i in countdown(n.edges.high, 0):
      if n.edges[i].int >= x.len:
        del(n.edges, i)
```

This is the graph post-processor.

After mutation, edges might point to nodes that don't exist.

Post-processor walks every edge. Prunes the invalid ones.

---

*Emphasis:*

Mutators **explore**. Post-processors **restore**.

---

*Visual anchors:*
- Left: code block
- Right-top: gold card "What it says"
- Right-bottom: cyan card "Why not encode everything in mutate?"

---

*Anchor cards:*

Gold card: "Edges may only point to nodes that exist."

Cyan card: separation of concerns. Mutation is creative. Post-processing is corrective.

---

*Transition:*

Now let me show you a real target. The graph demo.

---

## 14. SECTION — GRAPH TARGET

**Large centered title · Subtitle below**

---

Core message: nodes, edges, BFS, and **invariants** — a small graph library under fuzz.

---

*Delivery:*

Read the title: "Graph target."

Then the subtitle: nodes, edges, BFS, invariants.

This is a real Nim module. Real types. Real algorithms.

It's small enough to fit on slides. Complex enough to break.

---

*Visual anchors:*
- Large centered title
- Subtitle in muted
- Section label: TARGETS

---

*Transition:*

Here's the domain.

---

## 15. THE GRAPH GIVES CHAOS SOME TOPOLOGY
### DEMO · Left cards + right graph diagram

---

Core message: adjacency list, bounded **nodes** and **edges**, BFS as observable behavior.

---

*Rhythm:*

Left column. Walk the domain cards.

**Graph as adjacency list.** `Graph[T]` with `nodes: seq[Node[T]]`.

**Node indices as a distinct type.** `NodeIdx = distinct int`.

**Bounded node and edge counts.** MaxNodes = 8. MaxEdges = 2.

**BFS as observable behavior.** Run the traversal. Watch for crashes.

---

*Emphasis:*

**Distinct** type — that's the hook point for the custom mutator.

---

*Visual anchors:*
- Left: cyan card "Domain" + green callout "Target invariant"
- Right: graph diagram showing nodes 0-4 with colored edges
- Nodes in different accent colors, edges connecting them
- Bottom muted text: "A small adjacency list is enough"

---

*Anchor diagram:*

Point at the graph visual. "This is the target."

Nodes and edges. Node 0 is gold — that's the source.

The structure is tiny. That's intentional. Complexity comes from the combinations.

---

*Anchor callout:*

"Traversal should not crash, and every visited node should be reachable from the source."

This is the invariant we're checking.

---

*Transition:*

Now — how do we constrain the search space?

---

## 16. CONSTRAIN THE SEARCH SPACE
### MUTATORS · Code left + two cards right

---

Core message: **bounds** make the state space productive — this is not cheating.

---

*Rhythm:*

Left column. The custom mutator.

```nim
const MaxNodes = 8
const MaxEdges = 2

proc mutate(value: var NodeIdx; ...) =
  repeatMutate(mutateEnum(value.int, MaxNodes, r).NodeIdx)
```

`NodeIdx` is distinct. It gets its own mutator.

The mutator treats it as an enum: values 0 through MaxNodes.

No node 90 in a graph with 3 nodes. No infinite edge lists.

---

*Emphasis:*

**Bounds** — not cheating. Engineering.

---

*Visual anchors:*
- Left: code block with `mutate` for `NodeIdx`
- Right-top: gold card "This is not cheating"
- Right-bottom: cyan card "Use distinct types"

---

*Anchor cards:*

Gold card: the fuzzer still explores all combinations. It just stops inventing garbage.

Cyan card: distinct types get domain-specific mutators without changing production code.

---

*Transition:*

Here's the actual fuzz target for BFS.

---

## 17. TARGET SHAPE FOR BFS
### INVARIANTS · Code left + two cards right

---

Core message: start with **crash-only** — then add properties incrementally.

---

*Rhythm:*

Left column. The target.

```nim
func fuzzTarget(x: Graph[int8]) =
  when defined(dumpFuzzInput): debugEcho(x)
  if x.len > 0:
    discard x.breadthFirstSearch(source = 0.NodeIdx)
```

Minimal. Run BFS. Don't crash. That's the whole test.

`debugEcho` behind a compile flag — keep hot loops quiet.

---

*Emphasis:*

**Crash-only** is still valuable when the input has realistic shape.

---

*Visual anchors:*
- Left: code block
- Right-top: green card "Start small"
- Right-bottom: gold card "Then add properties"

---

*Anchor cards:*

Green card: a crash-only target is still useful. The generated input looks like a real graph.

Gold card: then add assertions. Remove an edge, preserve node count. Traverse, verify reachability.

---

*Transition:*

Now — the part everyone forgets. How do you compile this?

---

## 18. THE COMPILE LINE IS PART OF THE TOOL
### CONFIG · Terminal block + three cards

---

Core message: the compile flags are **explicit** — not hidden magic.

---

*Rhythm:*

Read the terminal block. Slowly.

`--cc:clang`. Required. libFuzzer is an LLVM feature.

`-d:useMalloc`. Nim's default allocator doesn't play with ASan.

`-t:"-fsanitize=fuzzer,address,undefined"`. The sanitizer flags.

`-l:...` — linker flags, same sanitizers.

`-d:nosignalhandler`. Let the fuzzer handle signals.

`--nomain:on`. libFuzzer provides main.

`--mm:arc`. Better fit for variants and modern Nim.

`-g`. Debug info.

---

*Emphasis:*

**Explicit** — every flag has a reason.

---

*Visual anchors:*
- Terminal block (dark panel, green text)
- Three cards below: clang (cyan), sanitizers (red), ARC/ORC (gold)

---

*Anchor terminal:*

Point at the terminal. "This goes in a config file. You don't type it every time."

---

*Transition:*

So you compile. You run. You get a crash. What now?

---

## 19. CRASH WORKFLOW
### PRACTICE · Three cards with arrows + callout

---

Core message: **find**, **reproduce**, **explain** — that's the loop.

---

*Rhythm:*

Walk the arrows. Three steps.

**Find.** Run fast. Sanitizers on. Minimal target. Let it run — hours, days. The fuzzer saves crashing inputs.

**Reproduce.** Recompile with debug info. Pass the crash artifact back in. Single-step in GDB.

**Explain.** Turn the crash into a regression test. Or a narrower invariant. The crash artifact IS the reproducer.

---

*Emphasis:*

The crash artifact **is** the reproducer.

---

*Visual anchors:*
- Three cards: red → cyan → green, connected by gold arrows
- Callout box below: "PRACTICAL NOTE" with gold left-border

---

*Anchor callout:*

"Use `debugEcho(x)` behind a flag when you need the generated Nim value."

"Keep hot fuzz loops quiet."

Practical. Actionable.

---

*Transition:*

So what makes a target worth writing?

---

## 20. WHAT MAKES A GOOD TARGET?
### CHECKLIST · Two-column Do / Avoid

---

Core message: **deterministic**, **fast**, clear property, bounded input.

---

*Rhythm:*

Left column. DO.

Keep it deterministic. Same input → same behavior. Always.

Keep it fast. Millions of runs. Every microsecond counts.

Check a clear property. Not "works correctly" — "BFS never crashes."

Prefer small typed inputs. Tuples, not giant config objects.

Bound uninteresting growth. MaxNodes, MaxEdges.

---

*Emphasis:*

**Deterministic** — non-negotiable.

---

*Rhythm continued:*

Right column. AVOID.

Don't print every case. Kills throughput.

Don't mutate the input value. The mutator owns that.

Don't depend on external services. No network, no filesystem.

Don't swallow crashes. Sanitizers need actual assertions.

Don't test five subsystems at once. One target, one property.

---

*Visual anchors:*
- Left: green card "Do" with bullet list
- Right: red card "Avoid" with bullet list

---

*Anchor cards:*

Scan down each list as you speak. Eye contact, then back to list.

---

*Transition:*

Where does drchaos really shine?

---

## 21. WHERE DRCHAOS IS SHARPEST
### FIT · Three cards + quote

---

Core message: **parsers**, **containers**, **stateful APIs** — these are the sweet spots.

---

*Rhythm:*

Three cards.

**Parsers and printers.** Roundtrip properties. AST variants. Escaping rules. Boundary values.

**Containers.** Insert/delete invariants. Iterator safety. Empty data edge cases.

**Stateful APIs.** Command sequences. Model checks. Generated histories. Offline simulations.

---

*Emphasis:*

**Roundtrip** — parse, print, compare. That's a property the fuzzer can check automatically.

---

*Visual anchors:*
- Three cards: cyan, gold, green
- Quote below with gold left-border

---

*Anchor quote:*

"The fuzzer is not a proof."

"It is a persistent reviewer with unusual taste in inputs."

Read it. Let it land. Honest about limitations.

---

*Transition:*

Speaking of limitations —

---

## 22. KNOWN LIMITS
### BOUNDARIES · Two-column awkward / design response

---

Core message: drchaos has rough **edges** — and design responses for each.

---

*Rhythm:*

Left column. Currently awkward.

Polymorphic serialization. Type erasure complicates mutation.

Reference cycles. Can loop in serialization.

Raw pointers without user serializers. No automated mutation for `ptr`.

Object variants outside modern memory management. ARC/ORC required.

---

*Emphasis:*

**Awkward** — not broken. Manageable.

---

*Rhythm continued:*

Right column. Design responses.

Wrap raw pieces with explicit serializers.

Define `default` for non-nil refs.

Use distinct types to narrow fields.

Keep generated structure honest with `postProcess`.

---

*Visual anchors:*
- Left: red card "Currently awkward"
- Right: gold card "Design response"
- Each with bullet lists

---

*Anchor note:*

These are patterns, not blockers. Every fuzzing tool has edge cases. drchaos makes them visible and gives you tools.

---

*Transition:*

So — what's next?

---

## 23. SECTION — FUTURE DIRECTIONS

**Large centered title · Subtitle below**

---

Core message: richer mutators, stateful APIs, model-heavy **simulation**.

---

*Delivery:*

Read the title. Pause.

Subtitle: "Richer mutators, stateful APIs, and model-heavy simulation work."

This is the horizon. Not today's tool — tomorrow's direction.

---

*Visual anchors:*
- Large centered title: "Future directions"
- Subtitle in muted
- Section label: FUTURE

---

*Transition:*

Let me give you the thesis for the future.

---

## 24. FUTURE DIRECTIONS
### NEXT · Statement slide

---

Core message: less random **noise** — more domain signal.

---

*Rhythm:*

Read the statement. Let it sit.

"The next step is less random noise, more domain signal."

**Pause.**

Subtitle: "Richer mutator architecture, generated command streams, and offline simulation work all push the same direction."

"Make exploration resemble the system under test."

---

*Emphasis:*

**Resemble** — that's the word. The fuzzer should understand what it's testing.

---

*Visual anchors:*
- Statement text (46pt, bold, white)
- Subtitle below (20pt, muted)
- Green accent on the statement

---

*Beat:*

This isn't vague. Everything mentioned — command streams, simulation — connects to what we just showed.

The graph target with bounded nodes? That's domain signal.

The post-processor pruning invalid edges? That's domain signal.

The future is just more of that. Better architecture for it.

---

*Transition:*

Questions?

---

## 25. CLOSING
### CLOSE · Statement + credits grid

---

Core message: questions — **preferably** the kind that produce smaller reproducers.

---

*Rhythm:*

Read the statement: "Questions?"

Pause for the subtitle callback: "Preferably the kind that produce smaller reproducers."

Smile. Wait for the laugh. Let the room settle.

---

*Emphasis:*

**Smaller** reproducers — callback to the crash workflow. Witty. Grounded.

---

*Credits:*

Left column: PROJECT SUPPORT.

zah and Status funded drchaos. disruptek sponsored the work. Nim community testing made the rough edges visible.

Right column: THANK YOU.

Antonis Geralis — NimConf 2022.

---

*Visual anchors:*
- Statement: "Questions?" in gold (46pt)
- Subtitle in muted below
- Credits grid: two columns, small labels in gold and cyan

---

*Anchor credits:*

Point at the credits as you speak them. Eye contact.

---

*Closing beat:*

"Preferably the kind that produce smaller reproducers."

Wait.

Then: "I'm around all day. Come find me."
