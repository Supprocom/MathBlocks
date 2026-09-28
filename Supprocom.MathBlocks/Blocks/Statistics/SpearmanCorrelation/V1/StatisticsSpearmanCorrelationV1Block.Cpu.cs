namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.spearman-correlation@1</c> mathematical operation.</summary>
    public static double SpearmanCorrelation(IReadOnlyList<double> left, IReadOnlyList<double> right) => PearsonCorrelation(MathBlockVectorMath.Rank(left), MathBlockVectorMath.Rank(right));
}
