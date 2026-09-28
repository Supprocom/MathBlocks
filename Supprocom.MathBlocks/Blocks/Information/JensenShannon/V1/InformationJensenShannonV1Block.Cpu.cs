namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.jensen-shannon@1</c> mathematical operation.</summary>
    public static double JensenShannonDivergence(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var middle = new double[left.Count];
        for (var index = 0; index < middle.Length; index++)
            middle[index] = (left[index] + right[index]) / 2d;
        return 0.5d * (KullbackLeiblerDivergence(left, middle) + KullbackLeiblerDivergence(right, middle));
    }
}
