
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    public static Complex SquareRoot(Complex value)
    {
        if (value.Real == 0d && value.Imaginary == 0d)
            return new Complex(0d, value.Imaginary);
        var magnitude = Magnitude(value);
        return new Complex(Math.Sqrt((magnitude + value.Real) / 2d), Math.CopySign(Math.Sqrt((magnitude - value.Real) / 2d), value.Imaginary));
    }
}
