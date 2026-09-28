
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    /// <summary>Computes the <c>matrix.reshape@1</c> mathematical operation.</summary>
    public static MathBlockMatrix Reshape(IReadOnlyList<double> values, int rows, int columns) => new(rows, columns, values);
}
