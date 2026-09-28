
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.subtract@1</c> mathematical operation.</summary>
    public static Complex Subtract(Complex left, Complex right) => new(left.Real - right.Real, left.Imaginary - right.Imaginary);
}
