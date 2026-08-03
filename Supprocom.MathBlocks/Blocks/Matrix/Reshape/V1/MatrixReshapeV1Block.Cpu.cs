
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static MathBlockMatrix Reshape(IReadOnlyList<double> values, int rows, int columns) => new(rows, columns, values);
}
