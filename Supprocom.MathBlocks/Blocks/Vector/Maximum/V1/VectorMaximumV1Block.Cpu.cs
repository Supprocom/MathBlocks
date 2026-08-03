namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double Maximum(IReadOnlyList<double> values)
    {
        var result = values[0];
        for (var index = 1; index < values.Count; index++)
            result = Math.Max(result, values[index]);
        return result;
    }
}
