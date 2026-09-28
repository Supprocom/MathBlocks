namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.cross-entropy@1</c> mathematical operation.</summary>
    public static double CrossEntropy(IReadOnlyList<double> probabilities, IReadOnlyList<double> reference)
    {
        ArgumentNullException.ThrowIfNull(probabilities);
        ArgumentNullException.ThrowIfNull(reference);
        var result = 0d;
        for (var index = 0; index < probabilities.Count; index++)
            if (probabilities[index] > 0d)
                result -= probabilities[index] * Math.Log(reference[index]);
        return result;
    }
}
