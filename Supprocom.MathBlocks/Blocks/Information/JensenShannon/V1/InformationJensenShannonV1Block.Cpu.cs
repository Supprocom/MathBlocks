namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double JensenShannonDivergence(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var middle = new double[left.Count];
        for (var index = 0; index < middle.Length; index++)
            middle[index] = (left[index] + right[index]) / 2d;
        return 0.5d * (KullbackLeiblerDivergence(left, middle) + KullbackLeiblerDivergence(right, middle));
    }
}
