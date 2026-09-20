# MathBlocks Development Guide

This guide covers prerequisites, native dependencies, source builds, tests,
package boundaries, and repository hygiene for MathBlocks 0.5.0.

## Source-only repository

The Git repository contains source text and project metadata only. It does not
contain or redistribute NVIDIA, CUDA, TorchSharp, or LibTorch binaries.

NuGet downloads declared dependencies into the user package cache outside the
repository. Build and restore outputs must remain ignored and must not be
committed or redistributed as repository content.

## Prerequisites

MathBlocks targets .NET 10. CPU development needs the .NET 10 SDK; CUDA
development and CUDA tests additionally need compatible NVIDIA hardware,
drivers, and toolkit support.

| Environment | Required runtime packages |
| --- | --- |
| Windows CUDA | x64 Windows, `libtorch-cuda-12.8-win-x64-part1` 2.10.0, and `libtorch-cuda-12.8-win-x64-part8` 2.10.0 |
| Linux CUDA | x64 Linux and `TorchSharp-cuda-linux` 0.107.0 with its declared dependencies |
| CPU-only build and portable tests | .NET 10 SDK |

The package declares the same native-acquisition dependency graph on every
pack host. Review each third-party license before use; recorded identities and
terms are in [THIRD-PARTY-NOTICES.md](../THIRD-PARTY-NOTICES.md).

## Restore

Restore the test project to acquire the production, test, generator, and native
package graph.

```text
dotnet restore Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj
```

Security-sensitive CI restores use `NuGetAuditMode=all` and isolated artifact
paths.

## Build and test

Build warnings are treated as errors. The standard local commands are:

```text
dotnet build Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj --configuration Release
dotnet test Supprocom.MathBlocks.Tests/Supprocom.MathBlocks.Tests.csproj --configuration Release
```

Portable tests do not require a CUDA device. CUDA execution and performance
tests require a compatible NVIDIA driver, CUDA toolkit, and supported x64
platform.

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

The project license does not replace or modify the licenses of CUDA,
TorchSharp, LibTorch, source-generation, test, or other third-party packages.
