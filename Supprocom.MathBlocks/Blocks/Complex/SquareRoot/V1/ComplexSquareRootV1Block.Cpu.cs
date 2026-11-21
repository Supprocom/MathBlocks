
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.square-root@1</c> mathematical operation.</summary>
    public static Complex SquareRoot(Complex value)
    {
        if (value.Real == 0f && value.Imaginary == 0f)
            return new Complex(0f, value.Imaginary);
        var magnitude = Magnitude(value);
        return new Complex(Math.Sqrt((magnitude + value.Real) / 2f), Math.CopySign(Math.Sqrt((magnitude - value.Real) / 2f), value.Imaginary));
    }
}
