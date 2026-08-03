
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    public static Complex NaturalLogarithm(Complex value) => new(Math.Log(Magnitude(value)), Phase(value));
}
