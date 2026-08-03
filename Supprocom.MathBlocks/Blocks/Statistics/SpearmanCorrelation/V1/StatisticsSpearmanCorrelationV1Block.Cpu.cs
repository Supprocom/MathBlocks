namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double SpearmanCorrelation(IReadOnlyList<double> left, IReadOnlyList<double> right) => PearsonCorrelation(MathBlockVectorMath.Rank(left), MathBlockVectorMath.Rank(right));
}
