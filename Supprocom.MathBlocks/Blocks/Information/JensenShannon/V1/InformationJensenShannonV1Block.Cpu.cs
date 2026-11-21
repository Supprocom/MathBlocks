namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.jensen-shannon@1</c> mathematical operation.</summary>
    public static float JensenShannonDivergence(IReadOnlyList<float> left, IReadOnlyList<float> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var middle = new float[left.Count];
        for (var index = 0; index < middle.Length; index++)
            middle[index] = (left[index] + right[index]) / 2f;
        return 0.5f * (KullbackLeiblerDivergence(left, middle) + KullbackLeiblerDivergence(right, middle));
    }
}
