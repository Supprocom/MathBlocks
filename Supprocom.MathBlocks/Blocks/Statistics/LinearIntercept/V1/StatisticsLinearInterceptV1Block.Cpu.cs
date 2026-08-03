namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double LinearIntercept(IReadOnlyList<double> x, IReadOnlyList<double> y) => MathBlockVectorMath.Mean(y) - LinearSlope(x, y) * MathBlockVectorMath.Mean(x);
}
