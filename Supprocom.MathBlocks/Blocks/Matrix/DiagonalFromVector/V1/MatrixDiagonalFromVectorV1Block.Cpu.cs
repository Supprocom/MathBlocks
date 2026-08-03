
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static MathBlockMatrix DiagonalMatrix(IReadOnlyList<double> diagonal)
    {
        var result = new double[diagonal.Count * diagonal.Count];
        for (var index = 0; index < diagonal.Count; index++)
            result[index * diagonal.Count + index] = diagonal[index];
        return new MathBlockMatrix(diagonal.Count, diagonal.Count, result, true);
    }
}
