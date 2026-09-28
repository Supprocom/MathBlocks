using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Contains one nonthrowing OpenMath import outcome.</summary>
[DebuggerDisplay("Succeeded = {Succeeded}")]
public sealed class MathBlockOpenMathImportAttempt
{
    private MathBlockOpenMathImportAttempt(
        MathBlockOpenMathImportResult? result,
        MathBlockOpenMathDiagnostic? diagnostic)
    {
        Result = result;
        Diagnostic = diagnostic;
    }

    /// <summary>Gets a value that identifies a successful import.</summary>
    public bool Succeeded => Result is not null;

    /// <summary>Gets the imported result after success.</summary>
    public MathBlockOpenMathImportResult? Result { get; }

    /// <summary>Gets the diagnostic after failure.</summary>
    public MathBlockOpenMathDiagnostic? Diagnostic { get; }

    internal static MathBlockOpenMathImportAttempt Success(
        MathBlockOpenMathImportResult result) => new(result, null);

    internal static MathBlockOpenMathImportAttempt Failure(
        MathBlockOpenMathDiagnostic diagnostic) => new(null, diagnostic);
}
