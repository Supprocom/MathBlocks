namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.root-mean-square@1</c> mathematical operation.</summary>
    public static double RootMeanSquare(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Math.Sqrt(MathBlockVectorMath.Dot(values, values) / values.Count);
    }
}
