
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    public static Complex Subtract(Complex left, Complex right) => new(left.Real - right.Real, left.Imaginary - right.Imaginary);
}
