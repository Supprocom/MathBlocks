namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // The validity form of the lag is the validity of SequenceLag, with no values written.
    internal static void SequenceLagValidity(
        ReadOnlySpan<float> x,
        ReadOnlySpan<bool> available,
        ReadOnlySpan<float> counts,
        int distance,
        Span<bool> valid) => SequenceLag(x, available, counts, distance, 0f, default, valid);
}
