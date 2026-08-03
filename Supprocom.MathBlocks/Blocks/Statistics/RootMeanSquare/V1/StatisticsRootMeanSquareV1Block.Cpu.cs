namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double RootMeanSquare(IReadOnlyList<double> values) => Math.Sqrt(MathBlockVectorMath.Dot(values, values) / values.Count);
}
