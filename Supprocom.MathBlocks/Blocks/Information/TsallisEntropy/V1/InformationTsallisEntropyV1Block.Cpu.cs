namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double TsallisEntropy(IReadOnlyList<double> probabilities, double order)
    {
        if (order == 1d)
            return ShannonEntropy(probabilities);
        var sum = 0d;
        for (var index = 0; index < probabilities.Count; index++)
            sum += Math.Pow(probabilities[index], order);
        return (1d - sum) / (order - 1d);
    }
}
