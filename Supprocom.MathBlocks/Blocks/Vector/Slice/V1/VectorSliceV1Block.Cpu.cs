namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Slice(IReadOnlyList<double> values, int start, int length)
    {
        var result = new double[length];
        for (var index = 0; index < length; index++)
            result[index] = values[start + index];
        return result;
    }
}
