
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static MathBlockComplexMatrix PickMatrix(IReadOnlyList<Complex> nodes, IReadOnlyList<Complex> values)
    {
        var result = new Complex[nodes.Count * nodes.Count];
        for (var row = 0; row < nodes.Count; row++)
            for (var column = 0; column < nodes.Count; column++)
            {
                var numerator = MathBlockComplex.Subtract(new Complex(1d, 0d), MathBlockComplex.Multiply(values[row], MathBlockComplex.Conjugate(values[column])));
                var denominator = MathBlockComplex.Subtract(new Complex(1d, 0d), MathBlockComplex.Multiply(nodes[row], MathBlockComplex.Conjugate(nodes[column])));
                result[row * nodes.Count + column] = MathBlockComplex.Divide(numerator, denominator);
            }

        return new MathBlockComplexMatrix(nodes.Count, nodes.Count, result, true);
    }
}
