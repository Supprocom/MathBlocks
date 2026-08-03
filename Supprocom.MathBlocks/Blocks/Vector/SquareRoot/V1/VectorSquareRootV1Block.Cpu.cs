namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] SquareRoot(IReadOnlyList<double> values) => Map(values, Math.Sqrt);
}
