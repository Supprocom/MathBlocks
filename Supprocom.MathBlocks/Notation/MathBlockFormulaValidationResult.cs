using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Contains one formula document or program validation outcome.</summary>
[DebuggerDisplay("IsValid = {IsValid}")]
public sealed class MathBlockFormulaValidationResult
{
    internal MathBlockFormulaValidationResult(
        bool isValid,
        MathBlockFormulaDiagnostic? diagnostic)
    {
        IsValid = isValid;
        Diagnostic = diagnostic;
    }

    /// <summary>Gets a value that identifies a valid formula or exportable program.</summary>
    public bool IsValid { get; }

    /// <summary>Gets the first diagnostic after failure.</summary>
    public MathBlockFormulaDiagnostic? Diagnostic { get; }
}
