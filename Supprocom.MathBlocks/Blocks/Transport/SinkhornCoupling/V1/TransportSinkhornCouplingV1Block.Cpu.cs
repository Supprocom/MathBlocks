namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    public static MathBlockMatrix SinkhornCoupling(MathBlockMatrix cost, IReadOnlyList<double> leftMass, IReadOnlyList<double> rightMass, double regularization, int iterations)
    {
        var rows = cost.Rows;
        var columns = cost.Columns;
        var kernel = new double[rows * columns];
        for (var row = 0; row < rows; row++)
            for (var column = 0; column < columns; column++)
                kernel[row * columns + column] = MathBlockScalar.Exponential(-cost[row, column] / regularization);
        var leftScale = MathBlockCollectionPrimitives.Repeat(1d, rows);
        var rightScale = MathBlockCollectionPrimitives.Repeat(1d, columns);
        for (var iteration = 0; iteration < iterations; iteration++)
        {
            for (var row = 0; row < rows; row++)
            {
                var sum = 0d;
                for (var column = 0; column < columns; column++)
                    sum += kernel[row * columns + column] * rightScale[column];
                leftScale[row] = leftMass[row] / sum;
            }

            for (var column = 0; column < columns; column++)
            {
                var sum = 0d;
                for (var row = 0; row < rows; row++)
                    sum += kernel[row * columns + column] * leftScale[row];
                rightScale[column] = rightMass[column] / sum;
            }
        }

        var result = new double[rows * columns];
        for (var row = 0; row < rows; row++)
            for (var column = 0; column < columns; column++)
                result[row * columns + column] = leftScale[row] * kernel[row * columns + column] * rightScale[column];
        return new MathBlockMatrix(rows, columns, result, true);
    }
}
