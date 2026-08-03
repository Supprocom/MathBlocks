
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] WalshHadamard(IReadOnlyList<double> values)
    {
        var result = MathBlockCollectionPrimitives.Copy(values);
        for (var width = 1; width < result.Length; width *= 2)
        {
            for (var start = 0; start < result.Length; start += 2 * width)
            {
                for (var offset = 0; offset < width; offset++)
                {
                    var left = result[start + offset];
                    var right = result[start + width + offset];
                    result[start + offset] = left + right;
                    result[start + width + offset] = left - right;
                }
            }
        }

        var scale = 1d / Math.Sqrt(result.Length);
        for (var index = 0; index < result.Length; index++)
            result[index] *= scale;
        return result;
    }
}
