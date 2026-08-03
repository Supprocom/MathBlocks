namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] RollingVariance(IReadOnlyList<double> values, int width)
    {
        var deviations = RollingStandardDeviation(values, width);
        for (var index = 0; index < deviations.Length; index++)
            deviations[index] *= deviations[index];
        return deviations;
    }
}
