using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Identifies one operation symbol in the MathBlocks OpenMath profile.</summary>
[DebuggerDisplay("{Dictionary}:{Name}")]
public readonly record struct MathBlockOpenMathOperationSymbol(
    string Dictionary,
    string Name);

/// <summary>Describes one operation use in imported program order.</summary>
[DebuggerDisplay("{Ordinal}: node {NodeIndex}, {Operation.Identity}")]
public sealed class MathBlockOpenMathOperationOccurrence
{
    internal MathBlockOpenMathOperationOccurrence(
        int ordinal,
        int nodeIndex,
        MathBlockOperation operation,
        MathBlockOpenMathOperationSymbol symbol)
    {
        Ordinal = ordinal;
        NodeIndex = nodeIndex;
        Operation = operation;
        Symbol = symbol;
    }

    /// <summary>Gets the zero-based occurrence ordinal.</summary>
    public int Ordinal { get; }

    /// <summary>Gets the program node index.</summary>
    public int NodeIndex { get; }

    /// <summary>Gets the exact standard operation.</summary>
    public MathBlockOperation Operation { get; }

    /// <summary>Gets the Profile 1 operation symbol.</summary>
    public MathBlockOpenMathOperationSymbol Symbol { get; }
}

/// <summary>Identifies one source position in a Profile 1 document.</summary>
[DebuggerDisplay("{ProfilePath}, line {Line}, column {Column}")]
public sealed class MathBlockOpenMathSourceLocation
{
    internal MathBlockOpenMathSourceLocation(string profilePath, int line, int column)
    {
        ProfilePath = profilePath;
        Line = line;
        Column = column;
    }

    /// <summary>Gets the stable Profile 1 path.</summary>
    public string ProfilePath { get; }

    /// <summary>Gets the one-based line number.</summary>
    public int Line { get; }

    /// <summary>Gets the one-based column number.</summary>
    public int Column { get; }
}
