
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.power@1</c> mathematical operation.</summary>
    public static Complex Power(Complex value, Complex exponent)
    {
        var logarithm = NaturalLogarithm(value);
        return Exponential(Multiply(exponent, logarithm));
    }
}
