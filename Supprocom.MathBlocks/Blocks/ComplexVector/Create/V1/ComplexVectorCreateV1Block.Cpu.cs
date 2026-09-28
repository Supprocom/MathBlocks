
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    /// <summary>Computes the <c>complex-vector.create@1</c> mathematical operation.</summary>
    public static Complex[] ComplexVector(IReadOnlyList<double> real, IReadOnlyList<double> imaginary)
    {
        ArgumentNullException.ThrowIfNull(imaginary);
        ArgumentNullException.ThrowIfNull(real);
        var result = new Complex[real.Count];
        for (var index = 0; index < result.Length; index++)
            result[index] = new Complex(real[index], imaginary[index]);
        return result;
    }
}
