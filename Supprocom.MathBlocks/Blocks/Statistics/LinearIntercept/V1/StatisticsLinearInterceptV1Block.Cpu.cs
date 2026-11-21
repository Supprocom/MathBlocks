namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.linear-intercept@1</c> mathematical operation.</summary>
    public static float LinearIntercept(IReadOnlyList<float> x, IReadOnlyList<float> y) => MathBlockVectorMath.Mean(y) - LinearSlope(x, y) * MathBlockVectorMath.Mean(x);
}
