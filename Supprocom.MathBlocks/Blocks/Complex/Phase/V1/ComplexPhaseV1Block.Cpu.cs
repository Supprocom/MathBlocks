
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.phase@1</c> mathematical operation.</summary>
    public static double Phase(Complex value) => Math.Atan2(value.Imaginary, value.Real);
}
