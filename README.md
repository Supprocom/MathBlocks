# MathBlocks

MathBlocks is an immutable mathematical-operation contract for deterministic CPU
and CUDA execution. It provides versioned operations, typed values, and
composable computation programs.

## Operation contract

Each operation has an identifier and a positive version. Its version binds
operand rules, output rules, units, shapes, capacity, scratch, validity, and
execution behavior.

The standard catalog contains 337 operations. Each operation has CPU regression
evidence, CUDA regression evidence, and a contract-shape performance target.

A caller can combine compatible operations in any directed acyclic graph.
Unknown versions and incompatible types fail before execution.

CPU and CUDA code stays in the single `Supprocom.MathBlocks` production
assembly. `Supprocom.MathBlocks.Cuda` is only a namespace in that assembly.

MathBlocks does not propose formulas. It does not own mutation, crossover,
selection, archives, cursors, or checkpoints.

## CPU composition

`MathBlockProgramBuilder` creates a typed program without reflection or internal
type names. `MathBlocksCPUWorker` executes independent nodes in parallel by
graph level.

This program calculates the area of a rectangle.

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

## CUDA composition

`MathBlockCudaDeviceModule` exposes the supported device source, complete
dispatch table, source fingerprint, and ABI fingerprint.

`MathBlockCudaDeviceModule.Operations` contains one public contract for each
standard operation. Each contract exposes its family, opcode, arity, rules,
execution behavior, and immutable fingerprint.

`ResolveOutputType` applies the CPU type contract. `PlanCUDA` applies the same
checked shape, capacity, and scratch authority as CUDA execution.

`MathBlockCudaSlotDescriptor` defines the 48-byte host and device slot.
`MathBlockCudaValueCodec` writes and reads every supported value kind without
internal types.

A consumer appends its CUDA kernel with `ComposeSource`. It can also compile the
complete source with `CompilePtx`.

The device function has this supported signature.

```text
__device__ void mathblocks_operation_dispatch(
    int family,
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
```

All threads in one 128-thread block must call the dispatcher uniformly. The
dispatcher completes one operation before the consumer calls the next operation.

This CUDA fragment composes addition and multiplication inside a consumer-owned
kernel.

```cuda
extern "C" __global__ void rectangle_area(MathBlockSlot* slots)
{
    if (blockIdx.x != 0)
        return;

    const MathBlockSlot* sum_inputs[2] = { &slots[0], &slots[1] };
    mathblocks_operation_dispatch(ADD_FAMILY, ADD_OPCODE, sum_inputs, 2, &slots[2]);

    const MathBlockSlot* area_inputs[2] = { &slots[2], &slots[3] };
    mathblocks_operation_dispatch(
        MULTIPLY_FAMILY,
        MULTIPLY_OPCODE,
        area_inputs,
        2,
        &slots[4]);
}
```

The host generates the four constants from
`MathBlockCudaDeviceModule.GetOperation`. Do not hardcode family or opcode
values in production code.

The external package gate compiles a consumer-owned CUDA kernel. It executes all
337 operation identities and one nested DAG in one launch.

The gate performs one immutable arena upload, one launch, one synchronization,
and one download. MathBlocks does not control that transaction.

## Managed CUDA programs

`MathBlocksCUDAWorker` compiles a typed program into one resident CUDA graph. It
remains a stateless operation utility.

The first input update performs one upload. A resident execution performs one
graph launch, one synchronization, and one output download.

Callers can queue resident executions before synchronization. The compiled
program serializes state changes for safe concurrent calls.

The exact parity policy requires CUDA results to match CPU results. Parity
includes data bits, shape, type, unit, and invalid state.

## Contract fingerprints

Each operation fingerprint binds its identity, version, family, opcode, arity,
rule identities, execution behavior, and device-source fingerprint.

It also binds every regression case and every performance-case input. The
performance iteration count and maximum warm latency are part of the same
identity.

The source fingerprint binds the exact CUDA definitions and dispatch
implementation. The ABI fingerprint binds the exact dispatcher signature, slot
layout, graph-edge layout, run layout, versioned value-codec schema, codec
implementation, source, and complete operation table.

A consumer must reject a stored ABI fingerprint that differs from the loaded
package. A package version change does not replace this check.

## Performance contract

Each operation has a sub-millisecond target on its contract shape. The CPU gate
measures warm p95 latency. The CUDA gate measures warm median latency.

These targets are test contracts. Results depend on hardware, input shape,
operating-system scheduling, percentile, and measurement method.

Rolling median and rolling quantile use exact order statistics without a
semantic window limit. General probabilities use linear radix preparation and
indexed sliding heaps.

The general work bound is `O(N log W)`. Quantile probabilities zero and one use
a linear monotonic deque and do not sort.

A width of one uses a parallel copy. Checked scratch arithmetic rejects an
unrepresentable resource requirement before launch.

## Source-only repository

This Git repository contains source text and project metadata only. It does not
contain or redistribute NVIDIA, CUDA, TorchSharp, or LibTorch binaries.

Get MathBlocks version `0.3.0` from NuGet.org with this command after
publication.

```text
dotnet add package Supprocom.MathBlocks --version 0.3.0
```

The package declares three external native-acquisition dependencies. This
dependency graph is the same on all pack hosts.

Install the .NET 10 SDK before project restore. Install a compatible NVIDIA
driver before CUDA execution.

Windows CUDA execution requires x64 Windows. It requires
`libtorch-cuda-12.8-win-x64-part1` and `libtorch-cuda-12.8-win-x64-part8`
version 2.10.0.

Linux CUDA execution requires x64 Linux and `TorchSharp-cuda-linux` version
0.107.0. That package supplies its declared Linux dependencies.

NuGet downloads all declared packages during restore. It stores them outside
this Git repository in the user package cache.

Use this command to restore the source tests.

```text
dotnet restore Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj
```

The build can copy runtime assets into ignored output directories. Do not commit
or redistribute those output directories.

Review each third-party license before package use. See
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md) for the recorded identities.

## Build and test

MathBlocks targets .NET 10. CUDA tests require a compatible NVIDIA driver and
CUDA toolkit.

```text
dotnet build Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj --configuration Release
dotnet test Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj --configuration Release
```

The external consumer project restores only the packed public package. It has no
project reference to the production project.

## License

MathBlocks uses the GNU Affero General Public License version 3 only. The SPDX
expression is `AGPL-3.0-only`.

The AGPL does not change third-party licenses for CUDA, TorchSharp, LibTorch, or
test packages. See [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
