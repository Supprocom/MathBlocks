# OpenMath and formula-interchange fuzz target

This SharpFuzz target drives the OpenMath program readers and both formula
interchange parsers. It covers string, contiguous and segmented UTF-8, stream,
validation, canonical re-export, visible OpenMath, visible Content MathML,
dictionary-group conflicts, and hostile XML shapes. Fixed document, node,
output, value, element, and nesting limits remain active.

The tracked corpus contains a canonical OpenMath program, partial input, valid
formula expressions in both vocabularies, a prohibited entity declaration,
foreign dictionary groups, and nested applications. Corpus replay checks every
seed without a fuzzing engine.

```powershell
dotnet run --project fuzz/MathBlocks.OpenMath.Fuzz -- --replay fuzz/MathBlocks.OpenMath.Fuzz/Corpus
```

Use SharpFuzz 2.3.0 to instrument both `MathBlockOpenMath` and
`MathBlockFormulaInterchange` in `Supprocom.MathBlocks.dll` before a fuzz run.
The CI workflow uses the pinned libfuzzer-dotnet release and retains the fuzz
evidence.
