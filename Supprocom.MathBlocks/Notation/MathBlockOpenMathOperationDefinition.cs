using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Describes one standard operation in OpenMath Profile 1.</summary>
[DebuggerDisplay("{Operation.Identity}: {Symbol.Dictionary}:{Symbol.Name}")]
public sealed class MathBlockOpenMathOperationDefinition
{
    internal MathBlockOpenMathOperationDefinition(
        MathBlockOperation operation,
        MathBlockOpenMathOperationSymbol symbol)
    {
        Operation = operation;
        Symbol = symbol;
    }

    /// <summary>Gets the exact standard operation instance.</summary>
    public MathBlockOperation Operation { get; }

    /// <summary>Gets the operation identity.</summary>
    public string Identity => Operation.Identity;

    /// <summary>Gets the operation arity.</summary>
    public int Arity => Operation.Arity;

    /// <summary>Gets the Profile 1 symbol.</summary>
    public MathBlockOpenMathOperationSymbol Symbol { get; }
}
