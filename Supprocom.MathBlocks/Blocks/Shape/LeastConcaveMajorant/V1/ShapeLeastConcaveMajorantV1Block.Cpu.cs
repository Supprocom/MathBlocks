
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>shape.least-concave-majorant@1</c> mathematical operation.</summary>
    public static double[] LeastConcaveMajorant(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return ShapeEnvelope(values, concave: true);
    }
}
