
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    /// <summary>Computes the <c>matrix.stack-rows@1</c> mathematical operation.</summary>
    public static MathBlockMatrix StackRows(IReadOnlyList<double> first, IReadOnlyList<double> second)
    {
        ArgumentNullException.ThrowIfNull(first);
        ArgumentNullException.ThrowIfNull(second);
        var result = new double[first.Count * 2];
        for (var index = 0; index < first.Count; index++)
        {
            result[index] = first[index];
            result[first.Count + index] = second[index];
        }

        return new MathBlockMatrix(2, first.Count, result, true);
    }
}
