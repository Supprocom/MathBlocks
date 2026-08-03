namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double TheilSenSlope(IReadOnlyList<double> x, IReadOnlyList<double> y)
    {
        var slopes = new List<double>(x.Count * (x.Count - 1) / 2);
        for (var first = 0; first < x.Count; first++)
        {
            for (var second = first + 1; second < x.Count; second++)
            {
                var difference = x[second] - x[first];
                if (difference != 0d)
                    slopes.Add((y[second] - y[first]) / difference);
            }
        }

        return MathBlockVectorMath.Median(slopes);
    }
}
