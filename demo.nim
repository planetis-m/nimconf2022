# Demo notes:
# Graph non-linear data structure with nodes and edges.
# Implemented as an adjacency list.
# Provide malformed input or valid with a post-processor.
# - Check for invariants such as:
# - upon completion every visited item is connected to the source.
# - contents of the queue are always sorted by distance.
# - ...

import std/[packedsets, deques]

type
  NodeIdx* = distinct int

  Graph*[T] = object
    nodes: seq[Node[T]]

  Node[T] = object
    data: T
    edges: seq[NodeIdx]

proc `$`(x: NodeIdx): string {.borrow.}
proc `==`(a, b: NodeIdx): bool {.borrow.}

proc len*[T](x: Graph[T]): int {.inline.} = x.nodes.len

proc `[]`*[T](x: Graph[T]; idx: NodeIdx): lent T {.inline.} = x.nodes[idx.int].data
proc `[]`*[T](x: var Graph[T]; idx: NodeIdx): var T {.inline.} = x.nodes[idx.int].data

proc addNode*[T](x: var Graph[T]; data: sink T): NodeIdx {.nodestroy.} =
  x.nodes.add Node[T](data: data, edges: @[])
  result = NodeIdx x.nodes.high

proc deleteNode*[T](x: var Graph[T]; idx: NodeIdx) =
  if idx.int < x.nodes.len:
    x.nodes.delete(idx)
    for n in x.nodes.mitems:
      if (let position = n.edges.find(idx); position != -1):
        n.edges.delete(position)

proc addEdge*[T](x: var Graph[T]; source, neighbor: NodeIdx) =
  if source.int < x.nodes.len and neighbor.int < x.nodes.len:
    x.nodes[source.int].edges.add(neighbor)

proc deleteEdge*[T](x: var Graph[T]; source, neighbor: NodeIdx) =
  if source < x.nodes.len and neighbor < x.nodes.len:
    template source: untyped = x.nodes[source.int]
    if (let neighborIdx = source.edges.find(neighbor.NodeIdx); neighborIdx != -1):
      template neighbor: untyped = source.edges[neighborIdx]
      source.edges.delete(neighborIdx)

proc breadthFirstSearch*[T](graph: Graph[T]; source: NodeIdx): seq[T] =
  var queue: Deque[NodeIdx]
  queue.addLast(source)

  result = @[graph[source]]
  var visited: PackedSet[NodeIdx]
  visited.incl source

  while queue.len > 0:
    let idx = queue.popFirst()
    template node: untyped = graph.nodes[idx.int]
    for neighbor in node.edges:
      if neighbor notin visited:
        queue.addLast(neighbor)
        visited.incl neighbor
        result.add(graph[neighbor])

when isMainModule:
  # import std/with
  #
  # proc main =
  #   var graph: Graph[string]
  #
  #   let a = graph.addNode("a")
  #   let b = graph.addNode("b")
  #   let c = graph.addNode("c")
  #   let d = graph.addNode("d")
  #   let e = graph.addNode("e")
  #   let f = graph.addNode("f")
  #   let g = graph.addNode("g")
  #   let h = graph.addNode("h")
  #
  #   with graph:
  #     addEdge(a, neighbor = b)
  #     addEdge(a, neighbor = c)
  #     addEdge(a, neighbor = d)
  #     addEdge(b, neighbor = e)
  #     addEdge(c, neighbor = f)
  #     addEdge(c, neighbor = g)
  #     addEdge(e, neighbor = h)
  #     addEdge(e, neighbor = f)
  #     addEdge(f, neighbor = g)
  #
  #   echo graph.breadthFirstSearch(source = a)
  #
  # main()

  import drchaos/[mutator, common], std/random

  const
    MaxNodes = 8 # User defined, statically limits number of nodes.
    MaxEdges = 2 # Limits number of edges

  proc mutate(value: var NodeIdx; sizeIncreaseHint: int; enforceChanges: bool; r: var Rand) =
    repeatMutate(mutateEnum(value.int, MaxNodes, r).NodeIdx)

  proc mutate[T](value: var seq[Node[T]]; sizeIncreaseHint: int; enforceChanges: bool; r: var Rand) =
    repeatMutateInplace(mutateSeq(value, tmp, MaxNodes, sizeIncreaseHint, r))

  proc mutate(value: var seq[NodeIdx]; sizeIncreaseHint: int; enforceChanges: bool; r: var Rand) =
    repeatMutateInplace(mutateSeq(value, tmp, MaxEdges, sizeIncreaseHint, r))

  proc postProcess[T](x: var seq[Node[T]]; r: var Rand) =
    for n in x.mitems:
      for i in countdown(n.edges.high, 0):
        if n.edges[i].int >= x.len:
          del(n.edges, i)

  func fuzzTarget(x: Graph[int]) =
    when defined(dumpFuzzInput): debugEcho(x)
    if x.len > 0:
      discard x.breadthFirstSearch(source = 0.NodeIdx)

  defaultMutator(fuzzTarget)
