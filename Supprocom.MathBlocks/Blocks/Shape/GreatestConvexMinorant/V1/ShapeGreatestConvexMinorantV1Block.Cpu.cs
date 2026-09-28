
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>shape.greatest-convex-minorant@1</c> mathematical operation.</summary>
    public static double[] GreatestConvexMinorant(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return ShapeEnvelope(values, concave: false);
    }
}
