namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Select(IReadOnlyList<bool> condition, IReadOnlyList<double> whenTrue, IReadOnlyList<double> whenFalse)
    {
        var result = new double[condition.Count];
        for (var index = 0; index < result.Length; index++)
            result[index] = condition[index] ? whenTrue[index] : whenFalse[index];
        return result;
    }
}
