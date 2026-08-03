namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double HausdorffDistance(IReadOnlyList<MathBlockPoint> left, IReadOnlyList<MathBlockPoint> right) => Math.Max(DirectedHausdorff(left, right), DirectedHausdorff(right, left));
}
