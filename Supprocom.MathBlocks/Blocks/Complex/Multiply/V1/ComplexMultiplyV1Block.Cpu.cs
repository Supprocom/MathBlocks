
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.multiply@1</c> mathematical operation.</summary>
    public static Complex Multiply(Complex left, Complex right) => new(left.Real * right.Real - left.Imaginary * right.Imaginary, left.Real * right.Imaginary + left.Imaginary * right.Real);
}
