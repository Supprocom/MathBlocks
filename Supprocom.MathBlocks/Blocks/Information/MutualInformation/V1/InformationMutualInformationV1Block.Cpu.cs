namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double MutualInformation(MathBlockMatrix jointProbabilities)
    {
        var rowTotals = new double[jointProbabilities.Rows];
        var columnTotals = new double[jointProbabilities.Columns];
        for (var row = 0; row < jointProbabilities.Rows; row++)
        {
            for (var column = 0; column < jointProbabilities.Columns; column++)
            {
                var probability = jointProbabilities[row, column];
                rowTotals[row] += probability;
                columnTotals[column] += probability;
            }
        }

        var information = 0d;
        for (var row = 0; row < jointProbabilities.Rows; row++)
        {
            for (var column = 0; column < jointProbabilities.Columns; column++)
            {
                var probability = jointProbabilities[row, column];
                if (probability > 0d)
                    information += probability * Math.Log(probability / (rowTotals[row] * columnTotals[column]));
            }
        }

        return information;
    }
}
