# MathBlocks

MathBlocks is a deterministic, typed computation-graph runtime for parallel CPU
and CUDA execution. It builds reusable formulas from versioned operations and
typed values.

## Contract model

Each block is pure and input-independent. A block receives typed values and
does not depend on their domain meaning.

Formula builders select each operation by identifier and version. Unknown
versions fail before execution.

Programs form directed acyclic graphs (DAGs). The CPU worker runs independent
nodes in each graph level in parallel.

CPU and CUDA code stays in the single `Supprocom.MathBlocks` production
assembly. `Supprocom.MathBlocks.Cuda` is only a namespace in that assembly.

The exact parity policy requires each CUDA block to match its CPU regression
result. The comparison includes value data, shape, type, unit, and invalid
state.

Each block folder owns Definition, CPU, CUDA, and Tests files. The catalog
contains 337 block folders.

## Resident CUDA execution

CUDA compilation creates one resident CUDA graph for each compiled program.
The CUDA path has a one-upload, one-resident-CUDA-graph, one-download execution
contract.

Callers can queue resident replays before one synchronization and output read.
The compiled program serializes atomic state changes, which keeps concurrent
calls safe.

## Resident typed program search

MathBlocks compiles an immutable typed grammar and typed terminals into one
resident CUDA search cycle. The definition preserves exact scalar bits,
caller resource envelopes, validity history, objective bindings, and accepted
state.

Each program is a typed DAG. Its operation nodes contain an operation
identifier, a version, and backward operand indexes.

The first compile performs one immutable-data upload. Each cycle uses one graph
launch, one synchronization, and one compact download. Later cycles do not
upload immutable data again.

The resident cycle enumerates and evolves programs on the CUDA device. It
supports typed mutation, typed crossover, random immigrants, and deterministic
random state.

A caller can bind a typed objective DAG and resident numeric inputs. Program
outputs and objective inputs remain on the device. Only requested compact
results, fingerprints, counters, and accepted state return to the host.

Generic intrinsic objective sources expose expanded operation count, maximum
lookback, deterministic execution cost, and age. Each source has an exact
identity and a caller-selected direction.

Declared history counts and program lookback create a valid-row mask. Objective
evaluation and semantic fingerprinting use only declared valid rows.

Selection maintains Pareto, quality-diversity, and age state on the device.
Accepted checkpoints include the exact proposal cursor and deterministic random
state.

An incompatible checkpoint fails before CUDA execution. An unsuccessful cycle
does not replace the last accepted state.

The compiler measures the current program, objective, archive, payload, and
scratch capacities. A larger caller envelope can compile a larger resident
cycle without a permanent search-space limit.

The transition API preserves accepted trial identity across larger graph,
terminal, objective, and archive bands. It refreshes accepted programs under
the new resident definition before new proposals.

Every supplied grammar operation uses the same CUDA implementation as the CUDA
worker. Compilation fails if an operation has no supported CUDA identity.

Instrumentation reports graph instances, uploads, launches,
synchronizations, downloads, resident bytes, compact bytes, duplicate counts,
evaluated programs, and the accepted cursor.

## Parallel proposal waves

The search definition owns a `MathBlockProgramPopulationWavePolicy`.
`ProposalWaveSize` changes search semantics and checkpoint identity.

Every proposal in a wave reads one frozen accepted-state snapshot. Ordered
commit applies trial results after all candidates in that wave finish.

`SerialResident` evaluates each wave with one candidate lane.
`ParallelResident` assigns independent candidate slots to the requested lanes.

Fixed candidate chunks handle waves that are wider than the lane count. Chunk
boundaries do not change trial identities, objective bits, or accepted state.

Execution mode and requested lane count do not enter search identity. Thus, a
complete accepted checkpoint can resume across modes and lane counts.

Call `MeasurePopulationSearchCapacity` before compilation. The result reports
shared bytes, lane stride, working bytes, wave slots, peak bytes, and compact
bytes.

Compilation rejects an insufficient resident or compact envelope. The runtime
reserves the requested lane count and reports requested and active lanes
separately.

Given a completed search definition, compile four resident lanes as follows.

```csharp
using Supprocom.MathBlocks;
using Supprocom.MathBlocks.Cuda;

var worker = new MathBlocksCUDAWorker();
var options = new MathBlockProgramPopulationExecutionOptions(
    MathBlockProgramPopulationExecutionMode.ParallelResident,
    candidateLaneCount: 4);

var capacity = worker.MeasurePopulationSearchCapacity(definition, options);
using var search = worker.CompilePopulationSearch(definition, options);
var cycle = search.ExecuteCycle();

Console.WriteLine(capacity.PeakResidentBytes);
Console.WriteLine(cycle.Instrumentation.MaximumConcurrentCandidates);
```

## Geometry example

This program calculates the area of a rectangle with a versioned scalar block.

```csharp
using Supprocom.MathBlocks;

var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
var width = builder.Input("width", MathBlockType.Scalar());
var height = builder.Input("height", MathBlockType.Scalar());
var area = builder.Apply("scalar.multiply", inputs: [width, height]);
var program = builder.Output("area", area).Build();

var output = program.Evaluate(new Dictionary<string, MathBlockValue>
{
    ["width"] = MathBlockValue.Scalar(6d),
    ["height"] = MathBlockValue.Scalar(4d)
});

Console.WriteLine(output["area"].AsScalar());
```

## Performance contract

Each block has a sub-millisecond contract target on its contract shape. The CPU
gate measures warm p95 latency. The CUDA block gate measures warm median resident
latency.

The resident formula gate measures warm p99 latency. These gates are test
contracts and are not universal latency guarantees.

Results depend on hardware, input shape, operating-system scheduling,
percentile, and measurement method.

Parallel resident mode can be slower for small workloads. Package tests report
serial and parallel samples without claiming an advantage for every workload.

## Source-only repository

This Git repository contains source text and project metadata only. It does not
contain or redistribute NVIDIA, CUDA, TorchSharp, or LibTorch binaries.

Get MathBlocks version `0.2.1` from NuGet.org with this command:

```text
dotnet add package Supprocom.MathBlocks --version 0.2.1
```

The package declares three external native-acquisition dependencies. This
dependency graph is the same on all pack hosts.

Install the .NET 10 SDK before you restore the projects. Install a compatible
NVIDIA driver before you run CUDA code.

Windows CUDA execution requires x64 Windows and
`libtorch-cuda-12.8-win-x64-part1` 2.10.0. It also requires
`libtorch-cuda-12.8-win-x64-part8` 2.10.0.

Linux CUDA execution requires x64 Linux and `TorchSharp-cuda-linux` 0.107.0.
That package supplies its declared Linux dependencies.

NuGet can download all three declared packages during restore. It stores them
in the user's global package cache, outside this Git repository.

Use this command to get the declared packages:

```text
dotnet restore Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj
```

The build can copy runtime assets into ignored output directories. Do not
commit or redistribute those output directories.

Review and accept each third-party license before you use its package. See
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for the recorded identities.

## Build and test

MathBlocks targets .NET 10. CUDA tests require a compatible NVIDIA driver and
CUDA toolkit.

```text
dotnet build Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj --configuration Release
dotnet test Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj --configuration Release
```

## License

MathBlocks is licensed under GNU Affero General Public License version 3 only.
The SPDX expression is `AGPL-3.0-only`.

The AGPL does not change third-party licenses for CUDA, TorchSharp, LibTorch, or
test packages. See [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for the
dependency audit.
