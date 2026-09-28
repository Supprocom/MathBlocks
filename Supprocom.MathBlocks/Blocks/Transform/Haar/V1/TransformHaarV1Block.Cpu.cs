
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>transform.haar@1</c> mathematical operation.</summary>
    public static double[] HaarTransform(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = MathBlockCollectionPrimitives.Copy(values);
        var work = new double[values.Count];
        var length = values.Count;
        var scale = 1d / Math.Sqrt(2d);
        while (length > 1)
        {
            var half = length / 2;
            for (var index = 0; index < half; index++)
            {
                work[index] = (result[2 * index] + result[2 * index + 1]) * scale;
                work[half + index] = (result[2 * index] - result[2 * index + 1]) * scale;
            }

            for (var index = 0; index < length; index++)
                result[index] = work[index];
            length = half;
        }

        return result;
    }
}
