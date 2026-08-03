
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static MathBlockMatrix MinPlusMultiply(MathBlockMatrix left, MathBlockMatrix right)
    {
        var result = MathBlockCollectionPrimitives.Repeat(
            Math.PositiveInfinity,
            left.Rows * right.Columns);
        for (var row = 0; row < left.Rows; row++)
            for (var column = 0; column < right.Columns; column++)
                for (var inner = 0; inner < left.Columns; inner++)
                    result[row * right.Columns + column] = Math.Min(result[row * right.Columns + column], left[row, inner] + right[inner, column]);
        return new MathBlockMatrix(left.Rows, right.Columns, result, true);
    }
}
