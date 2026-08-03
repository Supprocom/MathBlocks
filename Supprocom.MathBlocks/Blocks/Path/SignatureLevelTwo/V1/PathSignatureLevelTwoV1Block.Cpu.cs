
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static MathBlockMatrix SignatureLevelTwo(MathBlockMatrix path)
    {
        var dimension = path.Columns;
        var result = new double[dimension * dimension];
        var cumulative = new double[dimension];
        for (var row = 1; row < path.Rows; row++)
        {
            var increment = new double[dimension];
            for (var column = 0; column < dimension; column++)
                increment[column] = path[row, column] - path[row - 1, column];
            for (var left = 0; left < dimension; left++)
            {
                for (var right = 0; right < dimension; right++)
                {
                    result[left * dimension + right] += cumulative[left] * increment[right] + 0.5d * increment[left] * increment[right];
                }
            }

            for (var column = 0; column < dimension; column++)
                cumulative[column] += increment[column];
        }

        return new MathBlockMatrix(dimension, dimension, result, true);
    }
}
