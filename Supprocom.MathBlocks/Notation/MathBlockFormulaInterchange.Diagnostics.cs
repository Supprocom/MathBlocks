using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Identifies one stable formula-interchange failure.</summary>
public enum MathBlockFormulaDiagnosticCode
{
    SourceNull,
    SourceEmpty,
    DocumentCharacterLimitExceeded,
    DocumentByteLimitExceeded,
    InvalidUtf8,
    InvalidXml,
    UnsupportedDocumentContent,
    MissingExactAnnotation,
    DuplicateExactAnnotation,
    InvalidExactAnnotation,
    VisibleExpressionMismatch,
    NoncanonicalSource,
    ProgramNull,
    InvalidOutputName,
    MissingOutput,
    OperationOutsideProfile,
    InvalidProgram
}

/// <summary>Describes one formula-interchange failure.</summary>
[DebuggerDisplay("{Code}: {Message}")]
public sealed class MathBlockFormulaDiagnostic
{
    internal MathBlockFormulaDiagnostic(
        MathBlockFormulaDiagnosticCode code,
        string message)
    {
        Code = code;
        Message = message;
    }

    /// <summary>Gets the stable machine-readable code.</summary>
    public MathBlockFormulaDiagnosticCode Code { get; }

    /// <summary>Gets the invariant English message.</summary>
    public string Message { get; }

    /// <inheritdoc />
    public override string ToString() => string.Concat(Code, ": ", Message);
}

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
