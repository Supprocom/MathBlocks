namespace Supprocom.MathBlocks;

/// <summary>Contains one exact formula imported from a supported XML vocabulary.</summary>
public sealed class MathBlockFormulaImportResult
{
    internal MathBlockFormulaImportResult(
        MathBlockOpenMathImportResult exactResult,
        string outputName,
        MathBlockFormulaFormat format)
    {
        Program = exactResult.Program;
        OutputName = outputName;
        Format = format;
        Operations = exactResult.Operations;
        OperationOccurrences = exactResult.OperationOccurrences;
    }

    /// <summary>Gets the imported single-output typed program.</summary>
    public MathBlockProgram Program { get; }

    /// <summary>Gets the selected output name.</summary>
    public string OutputName { get; }

    /// <summary>Gets the XML vocabulary used by the source.</summary>
    public MathBlockFormulaFormat Format { get; }

    /// <summary>Gets operation uses in program order.</summary>
    public IReadOnlyList<MathBlockOperation> Operations { get; }

    /// <summary>Gets operation occurrences in program order.</summary>
    public IReadOnlyList<MathBlockOpenMathOperationOccurrence> OperationOccurrences { get; }
}
