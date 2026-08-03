
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] SignatureLevelThree(MathBlockMatrix path)
    {
        var dimension = path.Columns;
        var first = new double[dimension];
        var second = new double[dimension * dimension];
        var third = new double[dimension * dimension * dimension];
        for (var row = 1; row < path.Rows; row++)
        {
            var increment = new double[dimension];
            for (var index = 0; index < dimension; index++)
                increment[index] = path[row, index] - path[row - 1, index];
            for (var left = 0; left < dimension; left++)
            {
                for (var middle = 0; middle < dimension; middle++)
                {
                    for (var right = 0; right < dimension; right++)
                    {
                        third[(left * dimension + middle) * dimension + right] += second[left * dimension + middle] * increment[right] + first[left] * increment[middle] * increment[right] / 2d + increment[left] * increment[middle] * increment[right] / 6d;
                    }

                    second[left * dimension + middle] += first[left] * increment[middle] + increment[left] * increment[middle] / 2d;
                }

                first[left] += increment[left];
            }
        }

        return third;
    }
}
