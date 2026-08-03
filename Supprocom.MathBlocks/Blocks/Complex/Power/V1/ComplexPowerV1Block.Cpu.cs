
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    public static Complex Power(Complex value, Complex exponent)
    {
        var logarithm = NaturalLogarithm(value);
        return Exponential(Multiply(exponent, logarithm));
    }
}
