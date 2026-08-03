namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double L1Norm(IReadOnlyList<double> values)
    {
        var absolute = new double[values.Count];
        for (var index = 0; index < values.Count; index++)
            absolute[index] = Math.Abs(values[index]);
        return Sum(absolute);
    }
}
