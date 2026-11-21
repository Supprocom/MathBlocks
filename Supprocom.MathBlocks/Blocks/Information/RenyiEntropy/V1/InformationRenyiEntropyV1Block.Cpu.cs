namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.renyi-entropy@1</c> mathematical operation.</summary>
    public static float RenyiEntropy(IReadOnlyList<float> probabilities, float order)
    {
        ArgumentNullException.ThrowIfNull(probabilities);
        if (order == 1f)
            return ShannonEntropy(probabilities);
        var sum = 0f;
        for (var index = 0; index < probabilities.Count; index++)
            sum += Math.Pow(probabilities[index], order);
        return Math.Log(sum) / (1f - order);
    }
}
