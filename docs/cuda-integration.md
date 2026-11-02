# MathBlocks CUDA Integration

This guide describes the public device module, consumer-owned kernel
composition, managed resident programs, fingerprints, parity rules, and
performance contracts in MathBlocks 0.6.0.

## Device module

`MathBlockCudaDeviceModule` exposes the complete supported CUDA source,
dispatch table, source fingerprint, and ABI fingerprint.

`MathBlockCudaDeviceModule.Operations` contains one immutable public contract
for each of the 537 standard operations. Each entry exposes its operation
identity, family, opcode, arity, rules, execution behavior, regression cases,
and fingerprint.

`ResolveOutputType` applies the CoreCLR type contract. `PlanCUDA` applies the
same checked shape, capacity, and scratch authority used by CUDA execution.

## Slot and value ABI

`MathBlockCudaSlotDescriptor` defines the 48-byte host and device slot.
`MathBlockCudaValueCodec` writes and reads every supported value kind without
using internal types.

The ABI fingerprint binds the dispatcher signature, slot layout, graph-edge
layout, run layout, versioned value-codec schema, codec implementation, device
source, and complete operation table. Consumers must reject stored state when
its ABI fingerprint differs from the loaded package.

## Consumer-owned kernels

A consumer can append its kernel with `ComposeSource` or compile the complete
source with `CompilePtx`. The supported dispatcher signature is:

```cuda
__device__ void mathblocks_operation_dispatch(
    int family,
    int opcode,
    const MathBlockSlot* const* inputs,
    int input_count,
    MathBlockSlot* output)
```

Every thread in one 128-thread block must call the dispatcher uniformly. One
operation must complete before the consumer calls the next operation.

```cuda
extern "C" __global__ void rectangle_area(MathBlockSlot* slots)
{
    if (blockIdx.x != 0)
        return;

    const MathBlockSlot* sum_inputs[2] = { &slots[0], &slots[1] };
    mathblocks_operation_dispatch(
        ADD_FAMILY,
        ADD_OPCODE,
        sum_inputs,
        2,
        &slots[2]);

    const MathBlockSlot* area_inputs[2] = { &slots[2], &slots[3] };
    mathblocks_operation_dispatch(
        MULTIPLY_FAMILY,
        MULTIPLY_OPCODE,
        area_inputs,
        2,
        &slots[4]);
}
```

Generate family and opcode constants from
`MathBlockCudaDeviceModule.GetOperation`; do not hardcode their numeric
values in production code.

## Consumer transaction ownership

The external package gate compiles a consumer-owned CUDA kernel and executes
all 537 operation identities plus one nested directed acyclic graph in one
launch.

That gate performs one immutable arena upload, one kernel launch, one
synchronization, and one download. MathBlocks supplies operation contracts and
device code but does not control the consumer's transaction.

## Managed CUDA programs

`MathBlocksCUDAWorker` compiles a typed `MathBlockProgram` into one resident
CUDA graph while remaining a stateless operation utility.

The first input update performs one upload. A resident execution performs one
graph launch, one synchronization, and one output download. Callers may queue
resident executions before synchronization, and the compiled program
serializes state changes for safe concurrent calls.

The parity policy requires CUDA results to match CoreCLR results, including data
bits, shape, type, unit, and invalid state.

A compiled CUDA program sizes its outputs from its prototype inputs; an execution whose result needs more than that planned capacity returns an invalid value, where CoreCLR computes it. Compile with a prototype that covers the largest shapes you'll execute.

On CUDA, a consumer kernel that calls mathblocks_operation_dispatch for an elementwise form with the public Opcode gets an invalid result when a vector argument is empty; MathBlocksCUDAWorker is not affected.

## Fingerprints

Each operation fingerprint binds its identity, version, family, opcode, arity,
rule identities, execution behavior, device-source fingerprint, regression
cases, performance-case inputs, performance iteration count, and maximum warm
latency.

The source fingerprint binds the exact CUDA definitions and dispatch
implementation. A package version check does not replace source or ABI
fingerprint validation.

MathBlocks 0.6.0 changes the generated CUDA source and the dispatch table. Their source, operation-table, and ABI
fingerprints differ from 0.5.2, so consumers with cached PTX or device state from 0.5.2 must rebuild them against the
loaded package.

## Performance contract

Every standard operation has a sub-millisecond target on its contract shape.
The CoreCLR gate measures warm p95 latency, while the CUDA gate measures warm
median latency.

These are test contracts rather than universal hardware claims. Results depend
on hardware, input shape, operating-system scheduling, percentile, and
measurement method.

Rolling median and rolling quantile use exact order statistics without a
semantic window limit. General probabilities use linear radix preparation and
indexed sliding heaps, with a general work bound of `O(N log W)`.

Quantile probabilities zero and one use a linear monotonic deque and do not
sort. A width of one uses a parallel copy. Checked scratch arithmetic rejects
an unrepresentable resource requirement before launch.

## Runtime prerequisites

MathBlocks composes and fingerprints the CUDA device module without any CUDA installation. Compiling and running it needs an NVIDIA device, its driver, and the NVRTC of an installed CUDA Toolkit 12.0 or later; the [development guide](development.md) lists the file names and the search order. MathBlocks does not ship NVIDIA binaries. `MathBlockCudaNvrtcLibrary.Current` reports the NVRTC version and file that compile the module, so a parity run can record them.
