namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double Minimum(IReadOnlyList<double> values)
    {
        var result = values[0];
        for (var index = 1; index < values.Count; index++)
            result = Math.Min(result, values[index]);
        return result;
    }
}
