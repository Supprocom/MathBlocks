namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.gini-impurity@1</c> mathematical operation.</summary>
    public static float GiniImpurity(IReadOnlyList<float> probabilities) => 1f - MathBlockVectorMath.Dot(probabilities, probabilities);
}
