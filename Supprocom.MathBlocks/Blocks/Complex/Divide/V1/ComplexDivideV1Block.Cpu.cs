
namespace Supprocom.MathBlocks;

public static partial class MathBlockComplex
{
    /// <summary>Computes the <c>complex.divide@1</c> mathematical operation.</summary>
    public static Complex Divide(Complex left, Complex right)
    {
        var denominator = right.Real * right.Real + right.Imaginary * right.Imaginary;
        return new Complex((left.Real * right.Real + left.Imaginary * right.Imaginary) / denominator, (left.Imaginary * right.Real - left.Real * right.Imaginary) / denominator);
    }
}
