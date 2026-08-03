
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] IsotonicRegression(IReadOnlyList<double> values)
    {
        var means = new double[values.Count];
        var weights = new int[values.Count];
        var starts = new int[values.Count];
        var blockCount = 0;
        for (var index = 0; index < values.Count; index++)
        {
            means[blockCount] = values[index];
            weights[blockCount] = 1;
            starts[blockCount] = index;
            blockCount++;
            while (blockCount >= 2 && means[blockCount - 2] > means[blockCount - 1])
            {
                var combinedWeight = weights[blockCount - 2] + weights[blockCount - 1];
                means[blockCount - 2] = (means[blockCount - 2] * weights[blockCount - 2] + means[blockCount - 1] * weights[blockCount - 1]) / combinedWeight;
                weights[blockCount - 2] = combinedWeight;
                blockCount--;
            }
        }

        var result = new double[values.Count];
        for (var block = 0; block < blockCount; block++)
        {
            var end = block + 1 < blockCount ? starts[block + 1] : values.Count;
            for (var index = starts[block]; index < end; index++)
                result[index] = means[block];
        }

        return result;
    }
}
