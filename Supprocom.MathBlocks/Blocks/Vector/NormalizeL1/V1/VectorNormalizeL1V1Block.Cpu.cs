namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] NormalizeL1(IReadOnlyList<double> values)
    {
        var norm = L1Norm(values);
        return Scale(values, 1d / norm);
    }
}
