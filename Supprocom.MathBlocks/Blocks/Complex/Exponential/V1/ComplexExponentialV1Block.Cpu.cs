
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.exponential@1</c> mathematical operation.</summary>
    public static Complex Exponential(Complex value)
    {
        var scale = Math.Exp(value.Real);
        return new Complex(scale * Math.Cos(value.Imaginary), scale * Math.Sin(value.Imaginary));
    }
}
