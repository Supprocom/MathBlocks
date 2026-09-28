using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Describes the total formula mapping for one standard operation.</summary>
[DebuggerDisplay("{Operation.Identity}: {Symbol.Dictionary}:{Symbol.Name}")]
public sealed class MathBlockFormulaOperationMapping
{
    internal MathBlockFormulaOperationMapping(
        MathBlockOperation operation,
        MathBlockFormulaMappingClassification classification,
        MathBlockFormulaMappingKind kind,
        MathBlockFormulaSymbol symbol)
    {
        Operation = operation;
        Classification = classification;
        Kind = kind;
        Symbol = symbol;
    }

    /// <summary>Gets the exact standard operation instance.</summary>
    public MathBlockOperation Operation { get; }

    /// <summary>Gets the immutable operation identity.</summary>
    public string Identity => Operation.Identity;

    /// <summary>Gets the operation arity.</summary>
    public int Arity => Operation.Arity;

    /// <summary>Gets the mapping classification.</summary>
    public MathBlockFormulaMappingClassification Classification { get; }

    /// <summary>Gets the symbol provenance.</summary>
    public MathBlockFormulaMappingKind Kind { get; }

    /// <summary>Gets the symbol used by every supported formula vocabulary.</summary>
    public MathBlockFormulaSymbol Symbol { get; }
}
