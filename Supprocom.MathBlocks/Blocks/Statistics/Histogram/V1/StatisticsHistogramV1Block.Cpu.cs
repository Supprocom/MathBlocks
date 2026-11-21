namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.histogram@1</c> mathematical operation.</summary>
    public static float[] Histogram(IReadOnlyList<float> values, IReadOnlyList<float> boundaries)
    {
        ArgumentNullException.ThrowIfNull(boundaries);
        ArgumentNullException.ThrowIfNull(values);
        var counts = new float[boundaries.Count + 1];
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
