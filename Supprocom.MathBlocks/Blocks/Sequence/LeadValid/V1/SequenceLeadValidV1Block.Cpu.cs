namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // The validity form of the lead is the validity of SequenceLead, with no values written.
    internal static void SequenceLeadValidity(
        ReadOnlySpan<float> x,
        ReadOnlySpan<bool> available,
        ReadOnlySpan<float> counts,
        int distance,
        Span<bool> valid) => SequenceLead(x, available, counts, distance, 0f, default, valid);
}
