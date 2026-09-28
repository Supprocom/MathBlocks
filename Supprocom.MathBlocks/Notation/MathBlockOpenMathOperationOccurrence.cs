using System.Diagnostics;

namespace Supprocom.MathBlocks;

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
