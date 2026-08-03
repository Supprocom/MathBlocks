namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double BinaryShannonEntropy(IReadOnlyList<double> probabilities) => ShannonEntropy(probabilities) / Math.Log(2d);
}
