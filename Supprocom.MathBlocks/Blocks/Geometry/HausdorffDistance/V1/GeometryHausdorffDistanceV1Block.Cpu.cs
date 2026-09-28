namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.hausdorff-distance@1</c> mathematical operation.</summary>
    public static double HausdorffDistance(IReadOnlyList<MathBlockPoint> left, IReadOnlyList<MathBlockPoint> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        return Math.Max(DirectedHausdorff(left, right), DirectedHausdorff(right, left));
    }
}
