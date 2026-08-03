namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double GiniImpurity(IReadOnlyList<double> probabilities) => 1d - MathBlockVectorMath.Dot(probabilities, probabilities);
}
