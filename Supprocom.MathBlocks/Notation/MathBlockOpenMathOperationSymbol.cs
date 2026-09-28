using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Identifies one operation symbol in the MathBlocks OpenMath profile.</summary>
[DebuggerDisplay("{Dictionary}:{Name}")]
public readonly record struct MathBlockOpenMathOperationSymbol(
    string Dictionary,
    string Name);
