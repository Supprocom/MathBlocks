# MathBlocks

MathBlocks is a .NET 10 library for immutable, typed computation graphs with
deterministic CPU and CUDA execution. Its standard catalog contains 337
versioned mathematical operations, and every operation can be exchanged
through both OpenMath 2.0 and Strict Content MathML 3.0.

## Install

Install the `Supprocom.MathBlocks` package from NuGet.org; CUDA execution also
requires the platform dependencies described in the
[development guide](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/development.md).

```text
dotnet add package Supprocom.MathBlocks --version 0.5.1
```

## Build a program

Use `MathBlockProgramBuilder` to create a type-checked directed acyclic graph,
then evaluate it with named inputs; the
[programming model](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/programming-model.md) explains contracts, versions,
values, execution, and ownership boundaries.

```csharp
using Supprocom.MathBlocks;

var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
var width = builder.Input("width", MathBlockType.Scalar());
var height = builder.Input("height", MathBlockType.Scalar());
var area = builder.Apply("scalar.multiply", inputs: [width, height]);
var program = builder.Output("area", area).Build();

var result = program.Evaluate(new Dictionary<string, MathBlockValue>
{
    ["width"] = MathBlockValue.Scalar(6d),
    ["height"] = MathBlockValue.Scalar(4d)
});

Console.WriteLine(result["area"].AsScalar());
```

## Exchange formulas

`MathBlockOpenMath` preserves a complete typed program, while
`MathBlockFormulaInterchange` projects one selected output as conventional
OpenMath or Content MathML with an exact semantic annotation; all 337 standard
operations have direct mappings.

```csharp
var mathMl = MathBlockFormulaInterchange.Export(
    program,
    "area",
    MathBlockFormulaFormat.ContentMathMl);

var imported = MathBlockFormulaInterchange.Import(
    mathMl,
    MathBlockFormulaFormat.ContentMathMl);
```

## Choose an API

Each public entry point has one focused responsibility, so consumers can use
notation, managed execution, or low-level CUDA composition independently.

| Goal | Entry point | Guide |
| --- | --- | --- |
| Build and evaluate a typed graph | `MathBlockProgramBuilder`, `MathBlockProgram` | [Programming model](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/programming-model.md) |
| Preserve a complete typed program | `MathBlockOpenMath` | [OpenMath API](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/openmath-api.md) |
| Exchange one standard formula | `MathBlockFormulaInterchange` | [Formula interchange API](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/formula-interchange-api.md) |
| Compose or run CUDA work | `MathBlockCudaDeviceModule`, `MathBlocksCUDAWorker` | [CUDA integration](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/cuda-integration.md) |

## Documentation

The README is intentionally brief; detailed contracts, limits, dependencies,
security rules, performance targets, and contributor commands live in the
guides below.

| Topic | Document |
| --- | --- |
| Operations, values, programs, and CPU execution | [Programming model](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/programming-model.md) |
| Canonical full-program OpenMath | [OpenMath API](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/openmath-api.md) |
| OpenMath and Content MathML formula exchange | [Formula interchange API](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/formula-interchange-api.md) |
| Device dispatch, managed CUDA, ABI, and performance | [CUDA integration](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/cuda-integration.md) |
| Prerequisites, dependencies, build, test, and packaging | [Development guide](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/development.md) |

## Build from source

Install the .NET 10 SDK before restoring the repository; CUDA tests additionally
require a compatible NVIDIA driver and CUDA toolkit, as detailed in the
[development guide](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/docs/development.md).

```text
dotnet restore Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj
dotnet build Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj --configuration Release
dotnet test Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj --configuration Release
```

## License

MathBlocks is licensed under [AGPL-3.0-only](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/LICENSE.md); dependency notices and
their separate license terms are recorded in
[THIRD-PARTY-NOTICES.md](https://github.com/Supprocom/MathBlocks/blob/d032c8ee68c765e9a41e4f7ee43c89045d15aafb/THIRD-PARTY-NOTICES.md).
