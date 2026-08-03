
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static double[] SignatureLevelOne(MathBlockMatrix path)
    {
        var result = new double[path.Columns];
        for (var column = 0; column < path.Columns; column++)
            result[column] = path[path.Rows - 1, column] - path[0, column];
        return result;
    }
}
