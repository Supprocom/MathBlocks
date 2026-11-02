# MathBlocks Development Guide

This guide covers prerequisites, the CUDA requirement, source builds, tests,
package boundaries, and repository hygiene for MathBlocks 0.6.0.

## Source-only repository

The Git repository contains source text and project metadata only. Neither the repository nor the package
contains or redistributes NVIDIA or CUDA binaries.

NuGet downloads declared dependencies into the user package cache outside the
repository. Build and restore outputs must remain ignored and must not be
committed or redistributed as repository content.

## Prerequisites

MathBlocks targets .NET 10. CoreCLR development needs only the .NET 10 SDK. CUDA development and CUDA tests also need an NVIDIA device, its driver, and an installed CUDA Toolkit 12.0 or later. MathBlocks loads the driver and the toolkit's NVRTC at run time; it does not install or ship either.

| Environment | Requirement |
| --- | --- |
| Windows CUDA | x64 Windows, the NVIDIA driver (`nvcuda.dll`), and CUDA Toolkit 12.0 or later. MathBlocks looks for `nvrtc64_130_0.dll`, then `nvrtc64_120_0.dll`, in `%CUDA_PATH%\bin`, `%CUDA_PATH%\bin\x64`, and then each absolute `PATH` directory. |
| Linux CUDA | x64 Linux, the NVIDIA driver (`libcuda.so.1`), and CUDA Toolkit 12.0 or later. MathBlocks asks the system library loader for `libnvrtc.so.13`, then `libnvrtc.so.12`, then `libnvrtc.so`; the toolkit's library directory must be on the loader path (for example through `ldconfig` or `LD_LIBRARY_PATH`). |
| CoreCLR build and portable tests | .NET 10 SDK |

The package declares no dependencies. Use an NVRTC version new enough for your device's compute capability, and a driver that supports that CUDA version: a newer NVRTC can generate PTX that an older driver rejects. `MathBlockCudaNvrtcLibrary.Current` reports the NVRTC version and file in use. If no supported NVRTC is found, CUDA compilation fails with a message that lists every name and path searched. Recorded third-party identities and terms are in [THIRD-PARTY-NOTICES.md](../THIRD-PARTY-NOTICES.md).

## Restore

Restore the root solution to acquire the production, test, generator, and analyzer packages.

```text
dotnet restore MathBlocks.slnx --force-evaluate -p:NuGetAuditMode=all
```

Security-sensitive CI restores use `NuGetAuditMode=all` and isolated artifact
paths.

## Build and test

Build warnings are treated as errors. The standard local commands are:

```text
dotnet build MathBlocks.slnx --configuration Release --no-restore --no-incremental --warnaserror
dotnet test Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj --configuration Release --no-build --no-restore
```

Portable tests do not require a CUDA device. CUDA execution and performance
tests require an NVIDIA device and driver, CUDA Toolkit 12.0 or later, and x64 Windows or Linux.

## Analyzer policy

The solution build runs the .NET SDK `latest-all` rules, enforced code style,
Meziantou, Roslynator, Visual Studio Threading, Banned API, Hyperlinq, the
library Public API analyzer, and xUnit's test analyzer. Analyzer packages are
build-only (`PrivateAssets=all`) and are not runtime package dependencies.

`.editorconfig` records narrow exceptions where a rule conflicts with the
published 0.5.x API, versioned ABI or fingerprint bytes, or intentional test
semantics. The checked `BannedSymbols.txt` rejects obsolete crypto and unsafe
deserialization. `PublicAPI.Shipped.txt` freezes the previously published API;
new public members belong in `PublicAPI.Unshipped.txt` until a release baseline
is accepted. New warnings must be resolved before a candidate is packed.

To retain machine-readable diagnostic evidence, set
`-p:MathBlocksAnalyzerEvidence=/absolute/output/directory` on the solution
build. It writes one SARIF file per project.

## Generated CUDA source

The production build runs the checked source generator over the direct CUDA
translation units and compares generated device source with the committed
golden contract.

Generated source, binaries, restored packages, native libraries, test results,
and package evidence belong in ignored output or temporary directories. Do not
commit them.

## Package validation

The production package is built from
`Supprocom.MathBlocks/Supprocom.MathBlocks.csproj`. Package creation requires
an exact 40-character repository commit and a repository branch.

CI checks the nupkg and snupkg contents, repository metadata, assembly
provenance, Source Link, symbols, embedded profile artifacts, and SHA-256
evidence. It then restores
`Supprocom.MathBlocks.ExternalConsumer` from the packed package rather than a
project reference.

CI installs the CUDA Toolkit 12.8 NVRTC from NVIDIA's package repository and compiles the generated CUDA source and a consumer kernel with it, without a CUDA device. This catches CUDA compiler errors that a byte-for-byte
golden comparison cannot detect.

The external consumer validates public package use, formula mappings, embedded
artifacts, OpenMath and Content MathML round trips, and consumer-owned CUDA
composition.

## Documentation and profile artifacts

The package readme links the detailed guides under `docs/`. Versioned
OpenMath artifacts live under `openmath/v1/`, and formula-interchange
artifacts live under `formula/v1/`.

Profile artifacts have exact byte identities. Do not change their line endings
or content without regenerating their embedded authority and rerunning schema,
cross-platform checkout, and package gates.

## Licensing

MathBlocks uses the GNU Affero General Public License version 3 only. The SPDX
expression is `AGPL-3.0-only`.

The project license does not replace or modify the licenses of the NVIDIA driver, the CUDA Toolkit, source-generation, test, or other third-party packages.
