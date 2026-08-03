namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double L2Norm(IReadOnlyList<double> values) => Math.Sqrt(Dot(values, values));
}
