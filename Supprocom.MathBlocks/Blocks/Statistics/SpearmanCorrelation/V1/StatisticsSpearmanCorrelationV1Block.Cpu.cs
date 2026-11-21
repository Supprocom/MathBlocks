namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.spearman-correlation@1</c> mathematical operation.</summary>
    public static float SpearmanCorrelation(IReadOnlyList<float> left, IReadOnlyList<float> right) => PearsonCorrelation(MathBlockVectorMath.Rank(left), MathBlockVectorMath.Rank(right));
}
