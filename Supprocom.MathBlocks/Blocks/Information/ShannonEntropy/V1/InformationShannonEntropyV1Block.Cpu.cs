namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.shannon-entropy@1</c> mathematical operation.</summary>
    public static float ShannonEntropy(IReadOnlyList<float> probabilities)
    {
        ArgumentNullException.ThrowIfNull(probabilities);
        var entropy = 0f;
        for (var index = 0; index < probabilities.Count; index++)
            if (probabilities[index] > 0f)
                entropy -= probabilities[index] * Math.Log(probabilities[index]);
        return entropy;
    }
}
