using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Contains the Profile 1 export-validation result for one program.</summary>
[DebuggerDisplay("IsValid = {IsValid}")]
public sealed class MathBlockOpenMathProgramValidationResult
{
    internal MathBlockOpenMathProgramValidationResult(
        bool isValid,
        MathBlockOpenMathDiagnostic? diagnostic)
    {
        IsValid = isValid;
        Diagnostic = diagnostic;
    }

    /// <summary>Gets a value that identifies an exportable program.</summary>
    public bool IsValid { get; }

    /// <summary>Gets the first export diagnostic.</summary>
    public MathBlockOpenMathDiagnostic? Diagnostic { get; }
}
