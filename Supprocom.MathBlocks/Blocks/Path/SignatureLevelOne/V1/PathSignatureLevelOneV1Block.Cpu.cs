
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>path.signature-level-one@1</c> mathematical operation.</summary>
    public static float[] SignatureLevelOne(MathBlockMatrix path)
    {
        ArgumentNullException.ThrowIfNull(path);
        var result = new float[path.Columns];
        for (var column = 0; column < path.Columns; column++)
            result[column] = path[path.Rows - 1, column] - path[0, column];
        return result;
    }
}
