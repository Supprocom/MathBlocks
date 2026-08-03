
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    public static double Phase(Complex value) => Math.Atan2(value.Imaginary, value.Real);
}
