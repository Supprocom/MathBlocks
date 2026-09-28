
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.conjugate@1</c> mathematical operation.</summary>
    public static Complex Conjugate(Complex value) => new(value.Real, -value.Imaginary);
}
