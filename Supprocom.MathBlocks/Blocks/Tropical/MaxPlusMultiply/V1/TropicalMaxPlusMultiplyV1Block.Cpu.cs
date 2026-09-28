
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>tropical.max-plus-multiply@1</c> mathematical operation.</summary>
    public static MathBlockMatrix MaxPlusMultiply(MathBlockMatrix left, MathBlockMatrix right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var result = MathBlockCollectionPrimitives.Repeat(
            Math.NegativeInfinity,
            left.Rows * right.Columns);
        for (var row = 0; row < left.Rows; row++)
            for (var column = 0; column < right.Columns; column++)
                for (var inner = 0; inner < left.Columns; inner++)
                    result[row * right.Columns + column] = Math.Max(result[row * right.Columns + column], left[row, inner] + right[inner, column]);
        return new MathBlockMatrix(left.Rows, right.Columns, result, true);
    }
}
