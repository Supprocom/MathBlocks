namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // The validity form of the lead is the validity of SequenceLead, with no values written.
    internal static void SequenceLeadValidity(
        ReadOnlySpan<double> x,
        ReadOnlySpan<bool> available,
        ReadOnlySpan<double> counts,
        int distance,
        Span<bool> valid) => SequenceLead(x, available, counts, distance, 0d, default, valid);
}
