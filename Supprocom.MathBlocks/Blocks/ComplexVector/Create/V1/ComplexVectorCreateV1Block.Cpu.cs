
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static Complex[] ComplexVector(IReadOnlyList<double> real, IReadOnlyList<double> imaginary)
    {
        var result = new Complex[real.Count];
        for (var index = 0; index < result.Length; index++)
            result[index] = new Complex(real[index], imaginary[index]);
        return result;
    }
}
