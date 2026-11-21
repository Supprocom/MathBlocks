namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.cross-entropy@1</c> mathematical operation.</summary>
    public static float CrossEntropy(IReadOnlyList<float> probabilities, IReadOnlyList<float> reference)
    {
        ArgumentNullException.ThrowIfNull(probabilities);
        ArgumentNullException.ThrowIfNull(reference);
        var result = 0f;
        for (var index = 0; index < probabilities.Count; index++)
            if (probabilities[index] > 0f)
                result -= probabilities[index] * Math.Log(reference[index]);
        return result;
    }
}
