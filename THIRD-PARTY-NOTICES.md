# Third-party dependency notices

This document records the dependency identities reviewed for MathBlocks through
November 1, 2026. It does not replace the applicable license text.

The `AGPL-3.0-only` license applies to MathBlocks source. It does not change any
third-party license.

## CUDA source build tool

[`Supprocom.CSharp2CUDA` 0.3.1](https://www.nuget.org/packages/Supprocom.CSharp2CUDA/0.3.1)
is the direct build-tool dependency. Its NuGet metadata uses the
`AGPL-3.0-only` expression.

The package depends on
[`Microsoft.CodeAnalysis.CSharp` 5.6.0](https://www.nuget.org/packages/Microsoft.CodeAnalysis.CSharp/5.6.0).
That package and its Microsoft.CodeAnalysis dependency use MIT terms.

The MathBlocks build invokes the translator before production compilation. The
MathBlocks runtime package does not contain or depend on the translator or
Roslyn assemblies.

## Build-only analyzer packages

The repository pins [Meziantou.Analyzer 3.0.290](https://www.nuget.org/packages/Meziantou.Analyzer/3.0.290),
[Microsoft.VisualStudio.Threading.Analyzers 18.7.23](https://www.nuget.org/packages/Microsoft.VisualStudio.Threading.Analyzers/18.7.23),
[Microsoft.CodeAnalysis.BannedApiAnalyzers 5.6.0](https://www.nuget.org/packages/Microsoft.CodeAnalysis.BannedApiAnalyzers/5.6.0),
[Microsoft.CodeAnalysis.PublicApiAnalyzers 5.6.0](https://www.nuget.org/packages/Microsoft.CodeAnalysis.PublicApiAnalyzers/5.6.0),
and [NetFabric.Hyperlinq.Analyzer 2.3.0](https://www.nuget.org/packages/NetFabric.Hyperlinq.Analyzer/2.3.0)
under MIT terms. The Hyperlinq package carries an MIT `LICENSE` file.

[Roslynator.Analyzers 5.0.0](https://www.nuget.org/packages/Roslynator.Analyzers/5.0.0)
and test-only [xunit.analyzers 2.1.0](https://www.nuget.org/packages/xunit.analyzers/2.1.0)
use Apache-2.0 terms. All seven are build/test-only analyzer references with
`PrivateAssets=all`; none is a MathBlocks runtime package dependency.

## Test project

[`Markdig` 1.4.0](https://www.nuget.org/packages/Markdig/1.4.0) is a direct
test-only dependency used to parse the package README as CommonMark. Its NuGet
metadata uses the BSD-2-Clause expression. It is not included in the MathBlocks
runtime package.

Microsoft.NET.Test.Sdk 17.14.1 resolves Microsoft.CodeCoverage,
Microsoft.TestPlatform.ObjectModel, and Microsoft.TestPlatform.TestHost at
17.14.1. These Microsoft packages use the MIT expression.

Newtonsoft.Json 13.0.3 is a resolved test dependency and uses the MIT
expression.

xunit 2.9.3 resolves its core, assertion, abstraction, analyzer, and execution
packages. These packages use Apache-2.0 terms.

xunit.runner.visualstudio 3.1.1 is a direct test dependency and uses the
Apache-2.0 expression.

## Native system dependencies

MathBlocks calls the NVIDIA CUDA Driver API and NVRTC through native imports.
Both come from the user's system: the NVIDIA driver and an installed CUDA Toolkit 12.0 or later. Windows loads `nvcuda.dll` and `nvrtc64_130_0.dll` or `nvrtc64_120_0.dll`.

Linux loads `libcuda.so.1` and `libnvrtc.so.13`, `libnvrtc.so.12` or `libnvrtc.so`. Neither the driver nor NVRTC is part of MathBlocks, and the package contains no NVIDIA file.

A user who distributes an application that includes NVIDIA components must follow NVIDIA's license terms for them.
