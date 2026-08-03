
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    public static Complex Conjugate(Complex value) => new(value.Real, -value.Imaginary);
}
