namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] NormalizeL2(IReadOnlyList<double> values)
    {
        var norm = L2Norm(values);
        return Scale(values, 1d / norm);
    }
}
