namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // The validity form of the lag is the validity of SequenceLag, with no values written.
    internal static void SequenceLagValidity(
        ReadOnlySpan<double> x,
        ReadOnlySpan<bool> available,
        ReadOnlySpan<double> counts,
        int distance,
        Span<bool> valid) => SequenceLag(x, available, counts, distance, 0d, default, valid);
}
