using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Contains one nonthrowing formula import outcome.</summary>
[DebuggerDisplay("Succeeded = {Succeeded}")]
public sealed class MathBlockFormulaImportAttempt
{
    private MathBlockFormulaImportAttempt(
        MathBlockFormulaImportResult? result,
        MathBlockFormulaDiagnostic? diagnostic)
    {
        Result = result;
        Diagnostic = diagnostic;
    }

    /// <summary>Gets a value that identifies a successful import.</summary>
    public bool Succeeded => Result is not null;

    /// <summary>Gets the imported result after success.</summary>
    public MathBlockFormulaImportResult? Result { get; }

    /// <summary>Gets the diagnostic after failure.</summary>
    public MathBlockFormulaDiagnostic? Diagnostic { get; }

    internal static MathBlockFormulaImportAttempt Success(
        MathBlockFormulaImportResult result) => new(result, null);

    internal static MathBlockFormulaImportAttempt Failure(
        MathBlockFormulaDiagnostic diagnostic) => new(null, diagnostic);
}
