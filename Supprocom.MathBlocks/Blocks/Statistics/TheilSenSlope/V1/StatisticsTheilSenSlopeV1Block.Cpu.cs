namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.theil-sen-slope@1</c> mathematical operation.</summary>
    public static double TheilSenSlope(IReadOnlyList<double> x, IReadOnlyList<double> y)
    {
        ArgumentNullException.ThrowIfNull(x);
        ArgumentNullException.ThrowIfNull(y);
        var slopes = new List<double>(x.Count * (x.Count - 1) / 2);
        for (var first = 0; first < x.Count; first++)
        {
            for (var second = first + 1; second < x.Count; second++)
            {
                var difference = x[second] - x[first];
                // An overflowing difference, rise or slope would divide by an infinity (a zero slope) or put an infinity in the median; the result is not finite.
                if (!Math.IsFinite(difference))
                    return Math.NaN;
                if (difference != 0d)
                {
                    var rise = y[second] - y[first];
                    var slope = rise / difference;
                    if (!Math.IsFinite(rise) || !Math.IsFinite(slope))
                        return Math.NaN;
                    slopes.Add(slope);
                }
            }
        }

        return MathBlockVectorMath.Median(slopes);
    }
}
