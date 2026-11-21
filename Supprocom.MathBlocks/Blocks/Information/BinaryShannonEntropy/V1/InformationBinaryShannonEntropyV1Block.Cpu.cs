namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.binary-shannon-entropy@1</c> mathematical operation.</summary>
    public static float BinaryShannonEntropy(IReadOnlyList<float> probabilities) => ShannonEntropy(probabilities) / Math.Log(2f);
}
