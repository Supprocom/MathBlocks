namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.kullback-leibler@1</c> mathematical operation.</summary>
    public static float KullbackLeiblerDivergence(IReadOnlyList<float> probabilities, IReadOnlyList<float> reference)
    {
        ArgumentNullException.ThrowIfNull(probabilities);
        ArgumentNullException.ThrowIfNull(reference);
        var result = 0f;
        for (var index = 0; index < probabilities.Count; index++)
            if (probabilities[index] > 0f)
                result += probabilities[index] * Math.Log(probabilities[index] / reference[index]);
        return result;
    }
}
