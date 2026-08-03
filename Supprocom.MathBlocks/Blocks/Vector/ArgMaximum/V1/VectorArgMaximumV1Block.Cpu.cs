namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static int ArgMaximum(IReadOnlyList<double> values)
    {
        var result = 0;
        for (var index = 1; index < values.Count; index++)
            if (values[index] > values[result])
                result = index;
        return result;
    }
}
