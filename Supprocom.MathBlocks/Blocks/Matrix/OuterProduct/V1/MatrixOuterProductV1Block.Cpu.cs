
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static MathBlockMatrix OuterProduct(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var result = new double[left.Count * right.Count];
        for (var row = 0; row < left.Count; row++)
            for (var column = 0; column < right.Count; column++)
                result[row * right.Count + column] = left[row] * right[column];
        return new MathBlockMatrix(left.Count, right.Count, result, true);
    }
}
