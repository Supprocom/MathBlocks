namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.binary-shannon-entropy@1</c> mathematical operation.</summary>
    public static double BinaryShannonEntropy(IReadOnlyList<double> probabilities) => ShannonEntropy(probabilities) / Math.Log(2d);
}
