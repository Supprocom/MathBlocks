
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>geometry.fisher-rao-distance@1</c> mathematical operation.</summary>
    public static float FisherRaoDistance(IReadOnlyList<float> left, IReadOnlyList<float> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var affinity = 0f;
        for (var index = 0; index < left.Count; index++)
            affinity += MathBlockScalar.SquareRoot(left[index] * right[index]);
        return 2f * MathBlockScalar.ArcCosine(MathBlockScalar.Clamp(affinity, -1f, 1f));
    }
}
