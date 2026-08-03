
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static MathBlockMatrix CovarianceMatrix(MathBlockMatrix observations)
    {
        var means = new double[observations.Columns];
        for (var column = 0; column < observations.Columns; column++)
            for (var row = 0; row < observations.Rows; row++)
                means[column] += observations[row, column] / observations.Rows;
        var result = new double[observations.Columns * observations.Columns];
        for (var left = 0; left < observations.Columns; left++)
        {
            for (var right = left; right < observations.Columns; right++)
            {
                var sum = 0d;
                for (var row = 0; row < observations.Rows; row++)
                    sum += (observations[row, left] - means[left]) * (observations[row, right] - means[right]);
                var covariance = sum / observations.Rows;
                result[left * observations.Columns + right] = covariance;
                result[right * observations.Columns + left] = covariance;
            }
        }

        return new MathBlockMatrix(observations.Columns, observations.Columns, result, true);
    }
}
