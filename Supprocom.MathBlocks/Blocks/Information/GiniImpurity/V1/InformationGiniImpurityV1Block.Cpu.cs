namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.gini-impurity@1</c> mathematical operation.</summary>
    public static double GiniImpurity(IReadOnlyList<double> probabilities) => 1d - MathBlockVectorMath.Dot(probabilities, probabilities);
}
