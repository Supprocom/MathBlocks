
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] LeastConcaveMajorant(IReadOnlyList<double> values) => ShapeEnvelope(values, concave: true);
}
