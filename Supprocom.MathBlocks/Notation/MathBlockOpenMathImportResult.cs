namespace Supprocom.MathBlocks;

/// <summary>Contains one imported Profile 1 program and its operation metadata.</summary>
[System.Diagnostics.DebuggerDisplay("{Program.PlanNodes.Count} nodes, {Operations.Count} operations")]
public sealed class MathBlockOpenMathImportResult
{
    internal MathBlockOpenMathImportResult(
        MathBlockProgram program,
        IReadOnlyList<MathBlockOperation> operations,
        IReadOnlyList<MathBlockOpenMathOperationOccurrence> operationOccurrences,
        IReadOnlyDictionary<string, MathBlockOpenMathSourceLocation>? sourceLocations)
    {
        Program = program;
        Operations = Array.AsReadOnly(MathBlockCollectionPrimitives.Copy(operations));
        OperationOccurrences = Array.AsReadOnly(
            MathBlockCollectionPrimitives.Copy(operationOccurrences));
        SourceLocations = sourceLocations is null
            ? null
            : new System.Collections.ObjectModel.ReadOnlyDictionary<
                string,
                MathBlockOpenMathSourceLocation>(
                    new Dictionary<string, MathBlockOpenMathSourceLocation>(
                        sourceLocations,
                        StringComparer.Ordinal));
    }

    /// <summary>Gets the imported typed program.</summary>
    public MathBlockProgram Program { get; }

    /// <summary>Gets operations in program node order.</summary>
    public IReadOnlyList<MathBlockOperation> Operations { get; }

    /// <summary>Gets operation occurrences in program node order.</summary>
    public IReadOnlyList<MathBlockOpenMathOperationOccurrence> OperationOccurrences { get; }

    /// <summary>Gets captured source locations when the import requested them.</summary>
    public IReadOnlyDictionary<string, MathBlockOpenMathSourceLocation>? SourceLocations { get; }
}
