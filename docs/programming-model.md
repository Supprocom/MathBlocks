# MathBlocks Programming Model

This guide describes the standard operation catalog, typed program model, CPU
execution path, and ownership boundary of MathBlocks 0.5.0.

## Operation contracts

Each operation has a stable identifier and a positive version. The version
binds operand rules, output rules, units, shapes, capacity, scratch
requirements, validity behavior, and execution semantics.

The standard catalog contains 337 operations. Every standard operation carries
CPU regression evidence, CUDA regression evidence, and a contract-shape
performance target.

Unknown versions, unknown operation identifiers, incompatible input types, and
invalid shapes fail before execution. A caller may combine compatible
operations into any directed acyclic graph.

| Contract field | Purpose |
| --- | --- |
| Identifier and version | Select one immutable operation contract |
| Arity and input rules | Validate operands before execution |
| Output rule | Resolve the exact output type |
| Capacity and scratch rules | Bound storage and temporary resources |
| CPU and CUDA behavior | Define equivalent execution semantics |
| Regression and performance cases | Bind correctness and latency evidence |

## Program construction

`MathBlockProgramBuilder` creates a typed program without reflection or
internal type names. Inputs, constants, operation applications, and named
outputs become immutable program nodes.

```csharp
using Supprocom.MathBlocks;

var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
var width = builder.Input("width", MathBlockType.Scalar());
var height = builder.Input("height", MathBlockType.Scalar());
var area = builder.Apply("scalar.multiply", inputs: [width, height]);
var program = builder.Output("area", area).Build();
```

The builder validates each application against the selected catalog operation.
Nodes may be shared by multiple later operations, and a program may expose more
than one named output.

## CPU execution

`MathBlockProgram.Evaluate` evaluates a program from named
`MathBlockValue` inputs. `MathBlocksCPUWorker` executes independent nodes in
parallel by graph level while preserving the program's dependency order.

```csharp
var outputs = program.Evaluate(new Dictionary<string, MathBlockValue>
{
    ["width"] = MathBlockValue.Scalar(6d),
    ["height"] = MathBlockValue.Scalar(4d)
});

Console.WriteLine(outputs["area"].AsScalar());
```

The program remains a deterministic operation graph: execution does not
rewrite, simplify, or reorder it. Input and output values are explicit, and
type incompatibilities are rejected rather than coerced.

## CPU and CUDA parity

The same operation contract drives CPU type resolution, CPU execution, CUDA
planning, and CUDA dispatch. CUDA parity includes value bits, type, shape,
unit, and invalid state.

The managed and device-level CUDA paths are documented in
[CUDA integration](cuda-integration.md).

## Assembly boundary

CPU and CUDA APIs live in the single `Supprocom.MathBlocks` production
assembly. `Supprocom.MathBlocks.Cuda` is a namespace in that assembly, not a
second package or production binary.

The public contract exposes MathBlocks and system types. Consumers do not need
internal implementation types or reflection to build and run programs.

## Scope boundary

MathBlocks evaluates supplied operation graphs. It does not propose formulas
and does not own mutation, crossover, selection, archives, cursors, or
checkpoints.

OpenMath program serialization is documented in
[the OpenMath API guide](openmath-api.md). Formula projection for mathematics
software is documented in
[the formula interchange guide](formula-interchange-api.md).
