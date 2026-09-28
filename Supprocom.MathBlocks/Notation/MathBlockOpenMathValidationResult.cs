using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Contains a complete document-validation result.</summary>
[DebuggerDisplay("IsValid = {IsValid}, Canonicality = {Canonicality}")]
public sealed class MathBlockOpenMathValidationResult
{
    internal MathBlockOpenMathValidationResult(
        bool isValid,
        MathBlockOpenMathCanonicality canonicality,
        MathBlockOpenMathDiagnostic? diagnostic,
        long? differenceIndex,
        MathBlockOpenMathDifferenceUnit? differenceUnit)
    {
        IsValid = isValid;
        Canonicality = canonicality;
        Diagnostic = diagnostic;
        DifferenceIndex = differenceIndex;
        DifferenceUnit = differenceUnit;
    }

    /// <summary>Gets a value that identifies a valid Profile 1 document.</summary>
    public bool IsValid { get; }

    /// <summary>Gets the exact canonical state.</summary>
    public MathBlockOpenMathCanonicality Canonicality { get; }

    /// <summary>Gets the first diagnostic for invalid input.</summary>
    public MathBlockOpenMathDiagnostic? Diagnostic { get; }

    /// <summary>Gets the zero-based first canonical difference.</summary>
    public long? DifferenceIndex { get; }

    /// <summary>Gets the unit for the first canonical difference.</summary>
    public MathBlockOpenMathDifferenceUnit? DifferenceUnit { get; }
}
