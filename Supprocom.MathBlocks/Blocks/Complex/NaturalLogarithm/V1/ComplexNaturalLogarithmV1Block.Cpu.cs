
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.natural-logarithm@1</c> mathematical operation.</summary>
    public static Complex NaturalLogarithm(Complex value) => new(Math.Log(Magnitude(value)), Phase(value));
}
