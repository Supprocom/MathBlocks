
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] GreatestConvexMinorant(IReadOnlyList<double> values) => ShapeEnvelope(values, concave: false);
}
