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

CPU and GPU code stays in the single `Supprocom.MathBlocks` production
assembly. `Supprocom.MathBlocks.Gpu` is only a namespace in that assembly.

The exact parity policy requires each GPU block to match its CPU regression
result. The comparison includes value data, shape, type, unit, and invalid
state.

Each block folder owns Definition, CPU, GPU, and Tests files. The catalog
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

The resident cycle enumerates and evolves programs on the GPU. It supports
typed mutation, typed crossover, random immigrants, and deterministic random
state.

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

Every supplied grammar operation uses the same CUDA implementation as the GPU
worker. Compilation fails if an operation has no supported CUDA identity.

Instrumentation reports graph instances, uploads, launches,
synchronizations, downloads, resident bytes, compact bytes, duplicate counts,
evaluated programs, and the accepted cursor.

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
gate measures warm p95 latency. The GPU block gate measures warm median resident
latency.

The resident formula gate measures warm p99 latency. These gates are test
contracts and are not universal latency guarantees.

Results depend on hardware, input shape, operating-system scheduling,
percentile, and measurement method.

## Source-only repository

This Git repository contains source text and project metadata only. It does not
contain or redistribute NVIDIA, CUDA, TorchSharp, or LibTorch binaries.

Get MathBlocks version `0.1.4` from NuGet.org with this command:

```text
dotnet add package Supprocom.MathBlocks --version 0.1.4
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

MathBlocks targets .NET 10. CUDA tests require a compatible NVIDIA GPU and
driver.

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
