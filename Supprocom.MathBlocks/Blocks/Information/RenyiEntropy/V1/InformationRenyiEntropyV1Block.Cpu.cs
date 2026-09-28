namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.renyi-entropy@1</c> mathematical operation.</summary>
    public static double RenyiEntropy(IReadOnlyList<double> probabilities, double order)
    {
        ArgumentNullException.ThrowIfNull(probabilities);
        if (order == 1d)
            return ShannonEntropy(probabilities);
        var sum = 0d;
        for (var index = 0; index < probabilities.Count; index++)
            sum += Math.Pow(probabilities[index], order);
        return Math.Log(sum) / (1d - order);
    }
}
