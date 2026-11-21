namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.mutual-information@1</c> mathematical operation.</summary>
    public static float MutualInformation(MathBlockMatrix jointProbabilities)
    {
        ArgumentNullException.ThrowIfNull(jointProbabilities);
        var rowTotals = new float[jointProbabilities.Rows];
        var columnTotals = new float[jointProbabilities.Columns];
        for (var row = 0; row < jointProbabilities.Rows; row++)
        {
            for (var column = 0; column < jointProbabilities.Columns; column++)
            {
                var probability = jointProbabilities[row, column];
                rowTotals[row] += probability;
                columnTotals[column] += probability;
            }
        }

        var information = 0f;
        for (var row = 0; row < jointProbabilities.Rows; row++)
        {
            for (var column = 0; column < jointProbabilities.Columns; column++)
            {
                var probability = jointProbabilities[row, column];
                if (probability > 0f)
                    information += probability * Math.Log(probability / (rowTotals[row] * columnTotals[column]));
            }
        }

        return information;
    }
}
