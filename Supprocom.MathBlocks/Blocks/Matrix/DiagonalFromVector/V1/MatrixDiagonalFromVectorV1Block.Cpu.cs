
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    /// <summary>Computes the <c>matrix.diagonal-from-vector@1</c> mathematical operation.</summary>
    public static MathBlockMatrix DiagonalMatrix(IReadOnlyList<double> diagonal)
    {
        ArgumentNullException.ThrowIfNull(diagonal);
        var result = new double[diagonal.Count * diagonal.Count];
        for (var index = 0; index < diagonal.Count; index++)
            result[index * diagonal.Count + index] = diagonal[index];
        return new MathBlockMatrix(diagonal.Count, diagonal.Count, result, true);
    }
}
