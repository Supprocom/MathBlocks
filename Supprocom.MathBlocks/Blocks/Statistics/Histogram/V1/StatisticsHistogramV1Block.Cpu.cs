namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double[] Histogram(IReadOnlyList<double> values, IReadOnlyList<double> boundaries)
    {
        var counts = new double[boundaries.Count + 1];
        for (var valueIndex = 0; valueIndex < values.Count; valueIndex++)
        {
            var lower = 0;
            var upper = boundaries.Count;
            while (lower < upper)
            {
                var middle = lower + (upper - lower) / 2;
                if (values[valueIndex] <= boundaries[middle])
                    upper = middle;
                else
                    lower = middle + 1;
            }

            counts[lower]++;
        }

        return counts;
    }
}
