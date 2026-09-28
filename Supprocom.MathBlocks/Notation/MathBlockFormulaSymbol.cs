using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Identifies one OpenMath content-dictionary symbol.</summary>
[DebuggerDisplay("{Dictionary}:{Name}")]
public readonly record struct MathBlockFormulaSymbol(
    string ContentDictionaryBase,
    string Dictionary,
    string Name);
