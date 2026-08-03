
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static MathBlockMatrix Hankel(IReadOnlyList<double> firstColumn, IReadOnlyList<double> lastRow)
    {
        var sequence = MathBlockCollectionPrimitives.ConcatenateAfterFirst(firstColumn, lastRow);
        var result = new double[firstColumn.Count * lastRow.Count];
        for (var row = 0; row < firstColumn.Count; row++)
            for (var column = 0; column < lastRow.Count; column++)
                result[row * lastRow.Count + column] = sequence[row + column];
        return new MathBlockMatrix(firstColumn.Count, lastRow.Count, result, true);
    }
}
