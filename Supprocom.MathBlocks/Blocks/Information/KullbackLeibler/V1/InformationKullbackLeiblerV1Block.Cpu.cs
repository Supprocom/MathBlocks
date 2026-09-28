namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.kullback-leibler@1</c> mathematical operation.</summary>
    public static double KullbackLeiblerDivergence(IReadOnlyList<double> probabilities, IReadOnlyList<double> reference)
    {
        ArgumentNullException.ThrowIfNull(probabilities);
        ArgumentNullException.ThrowIfNull(reference);
        var result = 0d;
        for (var index = 0; index < probabilities.Count; index++)
            if (probabilities[index] > 0d)
                result += probabilities[index] * Math.Log(probabilities[index] / reference[index]);
        return result;
    }
}
