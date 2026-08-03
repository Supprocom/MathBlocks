
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    public static Complex Multiply(Complex left, Complex right) => new(left.Real * right.Real - left.Imaginary * right.Imaginary, left.Real * right.Imaginary + left.Imaginary * right.Real);
}
