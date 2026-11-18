namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// One measurement of a timing table: an operation on one input class, counts class and parameter, with the reference time taken at the same size. The ratios are filled in
/// by <see cref="ProofBar.Annotate"/> once every class of the same operation, counts class and parameter has been measured.
/// </summary>
/// <param name="operation">The operation name.</param>
/// <param name="className">The input class name.</param>
/// <param name="counts">The counts class name, or a dash when the operation has none.</param>
/// <param name="parameter">The parameter label.</param>
/// <param name="width">The size of the parameter that the cost may grow with.</param>
/// <param name="nanosecondsPerRow">The measured median time per row.</param>
/// <param name="referenceNanosecondsPerRow">The time per row of the reference: the main-era operation, or the inline baseline.</param>
/// <param name="secondReferenceNanosecondsPerRow">The time per row of a second reference, or zero when there is none.</param>
internal sealed class ProofCell(
    string operation,
    string className,
    string counts,
    string parameter,
    double width,
    double nanosecondsPerRow,
    double referenceNanosecondsPerRow,
    double secondReferenceNanosecondsPerRow)
{
    /// <summary>Gets the operation name.</summary>
    internal string Operation { get; } = operation;

    /// <summary>Gets the input class name.</summary>
    internal string ClassName { get; } = className;

    /// <summary>Gets the counts class name.</summary>
    internal string Counts { get; } = counts;

    /// <summary>Gets the parameter label.</summary>
    internal string Parameter { get; } = parameter;

    /// <summary>Gets the size of the parameter.</summary>
    internal double Width { get; } = width;

    /// <summary>Gets the measured time per row.</summary>
    internal double NanosecondsPerRow { get; } = nanosecondsPerRow;

    /// <summary>Gets the reference time per row.</summary>
    internal double ReferenceNanosecondsPerRow { get; } = referenceNanosecondsPerRow;

    /// <summary>Gets the second reference time per row.</summary>
    internal double SecondReferenceNanosecondsPerRow { get; } = secondReferenceNanosecondsPerRow;

    /// <summary>Gets or sets the time per row of the all-false full scan timed back to back with this cell, or zero when there is none.</summary>
    internal double FullScanNanosecondsPerRow { get; set; }

    /// <summary>Gets or sets the median over the classes of this operation, counts class and parameter.</summary>
    internal double MedianNanosecondsPerRow { get; set; }

    /// <summary>Gets or sets the time relative to the median class.</summary>
    internal double MedianRatio { get; set; }

    /// <summary>Gets or sets the time relative to the reference.</summary>
    internal double ReferenceRatio { get; set; }

    /// <summary>Gets or sets the time relative to the second reference.</summary>
    internal double SecondReferenceRatio { get; set; }

    /// <summary>Gets the key shared by the classes of one operation, counts class and parameter.</summary>
    internal string GroupKey => string.Concat(Operation, "|", Counts, "|", Parameter);

    /// <summary>Gets the key shared by the parameters of one operation, input class and counts class.</summary>
    internal string SeriesKey => string.Concat(Operation, "|", ClassName, "|", Counts);
}
