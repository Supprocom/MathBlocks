using System.Globalization;

namespace Supprocom.MathBlocks;

/// <summary>Describes which input rows an operation's output reads.</summary>
public sealed class MathBlockCausalityInfo
{
    private MathBlockCausalityInfo(MathBlockCausality kind, int? widthInputIndex)
    {
        Kind = kind;
        WidthInputIndex = widthInputIndex;
    }

    /// <summary>Gets the label for an operation whose output row t reads input row t only.</summary>
    public static MathBlockCausalityInfo Pointwise { get; } = new(MathBlockCausality.Pointwise, null);
    /// <summary>Gets the label for an operation whose output row t reads input rows 0 through t.</summary>
    public static MathBlockCausalityInfo Expanding { get; } = new(MathBlockCausality.Expanding, null);
    /// <summary>Gets the label for an operation whose output can read every input row.</summary>
    public static MathBlockCausalityInfo WholeSeries { get; } = new(MathBlockCausality.WholeSeries, null);
    /// <summary>Gets the label for an operation whose output row t reads input rows after t.</summary>
    public static MathBlockCausalityInfo Forward { get; } = new(MathBlockCausality.Forward, null);
    /// <summary>Gets the label for an operation that has no vector-kind input.</summary>
    public static MathBlockCausalityInfo NotSeries { get; } = new(MathBlockCausality.NotSeries, null);

    /// <summary>Gets the kind value.</summary>
    public MathBlockCausality Kind { get; }

    /// <summary>Gets the index of the scalar input that holds the window width w, for a Trailing operation only.</summary>
    public int? WidthInputIndex { get; }

    /// <summary>Creates the label for an operation whose output row t reads input rows t - w + 1 through t.</summary>
    /// <param name="widthInputIndex">The index of the scalar input that holds the window width w.</param>
    public static MathBlockCausalityInfo Trailing(int widthInputIndex)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(widthInputIndex);
        return new MathBlockCausalityInfo(MathBlockCausality.Trailing, widthInputIndex);
    }

    /// <summary>Gets the number of leading input rows that have no complete window.</summary>
    /// <remarks>
    /// A Trailing operation has width - 1 warm-up rows; every other kind has none. A Trailing operation that omits its
    /// warm-up rows, such as <c>sequence.rolling-maximum@1</c>, returns n - WarmUpRows(width) rows, so its output row j
    /// is input row j + WarmUpRows(width). An operation that returns n rows writes its warm-up rows in place.
    /// </remarks>
    /// <param name="width">The window width w.</param>
    public int WarmUpRows(int width)
    {
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(width);
        return Kind == MathBlockCausality.Trailing ? width - 1 : 0;
    }

    /// <summary>Returns the kind name, followed by <c>:</c> and the width input index for a Trailing label.</summary>
    public override string ToString() =>
        WidthInputIndex is { } index
            ? string.Create(CultureInfo.InvariantCulture, $"{Kind}:{index}")
            : Kind.ToString();
}
