namespace Supprocom.MathBlocks;

/// <summary>Identifies one stable formula-interchange failure.</summary>
public enum MathBlockFormulaDiagnosticCode
{
    /// <summary>Identifies the <c>SourceNull</c> value.</summary>
    SourceNull,
    /// <summary>Identifies the <c>SourceEmpty</c> value.</summary>
    SourceEmpty,
    /// <summary>Identifies the <c>DocumentCharacterLimitExceeded</c> value.</summary>
    DocumentCharacterLimitExceeded,
    /// <summary>Identifies the <c>DocumentByteLimitExceeded</c> value.</summary>
    DocumentByteLimitExceeded,
    /// <summary>Identifies the <c>InvalidUtf8</c> value.</summary>
    InvalidUtf8,
    /// <summary>Identifies the <c>InvalidXml</c> value.</summary>
    InvalidXml,
    /// <summary>Identifies the <c>UnsupportedDocumentContent</c> value.</summary>
    UnsupportedDocumentContent,
    /// <summary>Identifies the <c>MissingExactAnnotation</c> value.</summary>
    MissingExactAnnotation,
    /// <summary>Identifies the <c>DuplicateExactAnnotation</c> value.</summary>
    DuplicateExactAnnotation,
    /// <summary>Identifies the <c>InvalidExactAnnotation</c> value.</summary>
    InvalidExactAnnotation,
    /// <summary>Identifies the <c>VisibleExpressionMismatch</c> value.</summary>
    VisibleExpressionMismatch,
    /// <summary>Identifies the <c>NoncanonicalSource</c> value.</summary>
    NoncanonicalSource,
    /// <summary>Identifies the <c>ProgramNull</c> value.</summary>
    ProgramNull,
    /// <summary>Identifies the <c>InvalidOutputName</c> value.</summary>
    InvalidOutputName,
    /// <summary>Identifies the <c>MissingOutput</c> value.</summary>
    MissingOutput,
    /// <summary>Identifies the <c>OperationOutsideProfile</c> value.</summary>
    OperationOutsideProfile,
    /// <summary>Identifies the <c>InvalidProgram</c> value.</summary>
    InvalidProgram
}
