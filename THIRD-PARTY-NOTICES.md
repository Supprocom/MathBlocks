# Third-party dependency notices

This document records the dependency identities reviewed for MathBlocks on
August 12, 2026. It does not replace the applicable license text.

The `AGPL-3.0-only` license applies to MathBlocks source. It does not change any
third-party license.

## CUDA source build tool

[`Supprocom.CSharp2CUDA` 0.2.1](https://www.nuget.org/packages/Supprocom.CSharp2CUDA/0.2.1)
is the direct build-tool dependency. Its NuGet metadata uses the
`AGPL-3.0-only` expression.

The package depends on
[`Microsoft.CodeAnalysis.CSharp` 5.6.0](https://www.nuget.org/packages/Microsoft.CodeAnalysis.CSharp/5.6.0).
That package and its Microsoft.CodeAnalysis dependency use MIT terms.

The MathBlocks build invokes the translator before production compilation. The
MathBlocks runtime package does not contain or depend on the translator or
Roslyn assemblies.

## Production project on Windows

[`libtorch-cuda-12.8-win-x64-part1` 2.10.0](https://www.nuget.org/packages/libtorch-cuda-12.8-win-x64-part1/2.10.0)
and
[`libtorch-cuda-12.8-win-x64-part8` 2.10.0](https://www.nuget.org/packages/libtorch-cuda-12.8-win-x64-part8/2.10.0)
are direct Windows dependencies. Their NuGet metadata uses the MIT expression.

These package archives include LibTorch and native CUDA, cuBLAS, cuDNN, NVRTC,
and support libraries. The embedded `LICENSE-LIBTORCH.txt` notice includes MIT,
BSD-3-Clause, Apache-2.0, and zlib-family terms.

NVIDIA components remain subject to the NVIDIA SDK, CUDA Toolkit, and cuDNN
agreements. Review the
[CUDA 12.8 agreement](https://docs.nvidia.com/cuda/archive/12.8.1/eula/index.html)
and the
[cuDNN agreement](https://docs.nvidia.com/deeplearning/cudnn/backend/latest/)
before binary distribution.

## Production project on Linux

[`TorchSharp-cuda-linux` 0.107.0](https://www.nuget.org/packages/TorchSharp-cuda-linux/0.107.0)
is the direct Linux dependency. Its NuGet metadata uses the MIT expression.

This package depends on
[`TorchSharp` 0.107.0](https://www.nuget.org/packages/TorchSharp/0.107.0)
and
[`libtorch-cuda-12.8-linux-x64` 2.10.0](https://www.nuget.org/packages/libtorch-cuda-12.8-linux-x64/2.10.0).
Both parent packages use the MIT expression.

The Linux LibTorch parent package expands into 24 version 2.10.0 fragment
packages. Those packages contain LibTorch, CUDA, and related native components.

TorchSharp declares Google.Protobuf 3.21.9, SharpZipLib 1.4.0, SkiaSharp 2.88.6,
and System.Memory 4.5.5. Google.Protobuf uses BSD-3-Clause.

SharpZipLib, SkiaSharp, and System.Memory use MIT terms. SkiaSharp and its native
components retain their package notices.

## Test project

Microsoft.NET.Test.Sdk 17.14.1 resolves Microsoft.CodeCoverage,
Microsoft.TestPlatform.ObjectModel, and Microsoft.TestPlatform.TestHost at
17.14.1. These Microsoft packages use the MIT expression.

Newtonsoft.Json 13.0.3 is a resolved test dependency and uses the MIT
expression.

xunit 2.9.3 resolves its core, assertion, abstraction, analyzer, and execution
packages. These packages use Apache-2.0 terms.

xunit.runner.visualstudio 3.1.1 is a direct test dependency and uses the
Apache-2.0 expression.

## Native system dependencies and acquisition

MathBlocks calls the NVIDIA CUDA Driver API and NVRTC through native imports.
Windows loads `nvcuda.dll` and `nvrtc64_120_0.dll`.

Linux loads `libcuda.so.1` and an available `libnvrtc` version. The NVIDIA
driver is a system dependency and is not part of MathBlocks.

The Windows loader also calls `kernel32.dll`, which is an operating-system
component.

NuGet downloads the declared packages into the user's package cache. The
MathBlocks Git repository does not contain or redistribute these package
archives or their binary files.

A user who distributes compiled output must review each applicable third-party
license. NuGet metadata does not replace the notices inside native archives.

No MathBlocks package or release was produced during this migration.
