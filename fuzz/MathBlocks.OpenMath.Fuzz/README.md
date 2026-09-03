# OpenMath fuzz target

This SharpFuzz target drives the string, byte, sequence, and stream readers.
It applies fixed document, node, output, and value limits.

The tracked corpus contains one valid document and one partial document.
Corpus replay checks the target without a fuzzing engine.

```powershell
dotnet run --project fuzz/MathBlocks.OpenMath.Fuzz -- --replay fuzz/MathBlocks.OpenMath.Fuzz/Corpus
```

Use SharpFuzz 2.3.0 to instrument `Supprocom.MathBlocks.dll` before a fuzz run.
Use the pinned libfuzzer-dotnet release from the CI workflow.
