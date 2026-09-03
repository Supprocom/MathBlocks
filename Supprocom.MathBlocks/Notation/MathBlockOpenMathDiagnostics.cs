using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Identifies one stable OpenMath validation failure.</summary>
public enum MathBlockOpenMathDiagnosticCode
{
    SourceNull,
    SourceEmpty,
    ProgramNull,
    DocumentCharacterLimitExceeded,
    DocumentByteLimitExceeded,
    NodeLimitExceeded,
    OutputLimitExceeded,
    ValueElementLimitExceeded,
    InvalidUtf8,
    UnsupportedEncoding,
    InvalidXml,
    UnsupportedDocumentContent,
    MissingRoot,
    UnexpectedElement,
    MissingAttribute,
    UnsupportedAttribute,
    UnsupportedAttributeNamespace,
    UnsupportedOpenMathVersion,
    UnsupportedContentDictionaryBase,
    UnsupportedContentDictionaryGroup,
    InvalidProgramEnvelope,
    InvalidNodeCollection,
    InvalidNodeIdentifier,
    InvalidNodeOrder,
    InvalidInputNode,
    InvalidConstantNode,
    UnsupportedOperationSymbol,
    OperationArityMismatch,
    InvalidReference,
    ForwardReference,
    IncompatibleNodeTypes,
    InvalidOutput,
    UnsupportedType,
    InvalidUnit,
    InvalidRational,
    InvalidValueKind,
    InvalidValue,
    InvalidShape,
    InvalidBinary64,
    NonfiniteBinary64,
    OperationOutsideProfile,
    InvalidProgramNodeOrder,
    UnsupportedProgramNodeKind,
    InvalidProgramName,
    InvalidProgramType,
    InvalidProgramConstant,
    InvalidProgramOutput,
    InvalidProgram,
    NoncanonicalSourceRequired
}

/// <summary>Describes the first authoritative OpenMath failure.</summary>
[DebuggerDisplay("{Code}: {Message}")]
public sealed class MathBlockOpenMathDiagnostic
{
    internal MathBlockOpenMathDiagnostic(
        MathBlockOpenMathDiagnosticCode code,
        string message,
        int? line = null,
        int? column = null,
        string? profilePath = null,
        int? nodeIndex = null,
        string? operationIdentifier = null,
        string? dictionary = null,
        string? symbol = null)
    {
        Code = code;
        Message = message;
        Line = line;
        Column = column;
        ProfilePath = profilePath;
        NodeIndex = nodeIndex;
        OperationIdentifier = operationIdentifier;
        Dictionary = dictionary;
        Symbol = symbol;
    }

    /// <summary>Gets the stable diagnostic code.</summary>
    public MathBlockOpenMathDiagnosticCode Code { get; }

    /// <summary>Gets the invariant diagnostic message.</summary>
    public string Message { get; }

    /// <summary>Gets the one-based source line when it is available.</summary>
    public int? Line { get; }

    /// <summary>Gets the one-based source column when it is available.</summary>
    public int? Column { get; }

    /// <summary>Gets the stable Profile 1 path when it is available.</summary>
    public string? ProfilePath { get; }

    /// <summary>Gets the program node index when it is available.</summary>
    public int? NodeIndex { get; }

    /// <summary>Gets the operation identity when it is available.</summary>
    public string? OperationIdentifier { get; }

    /// <summary>Gets the content dictionary when it is available.</summary>
    public string? Dictionary { get; }

    /// <summary>Gets the symbol name when it is available.</summary>
    public string? Symbol { get; }

    /// <inheritdoc />
    public override string ToString() => string.Concat(Code, ": ", Message);
}

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
