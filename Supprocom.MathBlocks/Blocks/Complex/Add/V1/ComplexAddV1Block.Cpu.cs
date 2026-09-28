
namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Complex contract.</summary>
public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.add@1</c> mathematical operation.</summary>
    public static Complex Add(Complex left, Complex right) => new(left.Real + right.Real, left.Imaginary + right.Imaginary);
}
