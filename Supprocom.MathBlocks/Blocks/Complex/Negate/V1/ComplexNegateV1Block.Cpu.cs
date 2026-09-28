
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.negate@1</c> mathematical operation.</summary>
    public static Complex Negate(Complex value) => new(-value.Real, -value.Imaginary);
}
