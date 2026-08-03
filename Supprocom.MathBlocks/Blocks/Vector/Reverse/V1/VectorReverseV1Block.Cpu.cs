namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Reverse(IReadOnlyList<double> values)
    {
        var result = new double[values.Count];
        for (var index = 0; index < values.Count; index++)
            result[index] = values[values.Count - index - 1];
        return result;
    }
}
