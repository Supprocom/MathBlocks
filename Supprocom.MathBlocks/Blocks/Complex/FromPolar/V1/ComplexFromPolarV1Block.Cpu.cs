
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    public static Complex FromPolar(double magnitude, double phase) => new(magnitude * Math.Cos(phase), magnitude * Math.Sin(phase));
}
