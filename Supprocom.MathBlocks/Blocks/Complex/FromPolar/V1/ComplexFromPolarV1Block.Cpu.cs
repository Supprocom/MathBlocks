
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.from-polar@1</c> mathematical operation.</summary>
    public static Complex FromPolar(double magnitude, double phase) => new(magnitude * Math.Cos(phase), magnitude * Math.Sin(phase));
}
