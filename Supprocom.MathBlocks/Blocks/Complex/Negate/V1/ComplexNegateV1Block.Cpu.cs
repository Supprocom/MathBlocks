
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    public static Complex Negate(Complex value) => new(-value.Real, -value.Imaginary);
}
