namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.total-variation-distance@1</c> mathematical operation.</summary>
    public static float TotalVariationDistance(IReadOnlyList<float> left, IReadOnlyList<float> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var sum = 0f;
        for (var index = 0; index < left.Count; index++)
            sum += Math.Abs(left[index] - right[index]);
        return sum / 2f;
    }
}
