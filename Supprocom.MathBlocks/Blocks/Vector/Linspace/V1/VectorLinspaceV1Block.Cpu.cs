namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Linspace(double start, double end, int count)
    {
        var result = new double[count];
        if (count == 1)
        {
            result[0] = start;
            return result;
        }

        var step = (end - start) / (count - 1);
        for (var index = 0; index < count; index++)
            result[index] = index == count - 1 ? end : start + step * index;
        return result;
    }
}
