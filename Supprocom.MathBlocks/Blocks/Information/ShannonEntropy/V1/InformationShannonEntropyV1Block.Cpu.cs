namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double ShannonEntropy(IReadOnlyList<double> probabilities)
    {
        var entropy = 0d;
        for (var index = 0; index < probabilities.Count; index++)
            if (probabilities[index] > 0d)
                entropy -= probabilities[index] * Math.Log(probabilities[index]);
        return entropy;
    }
}
