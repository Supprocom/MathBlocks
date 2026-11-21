
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>markov.stationary-distribution@1</c> mathematical operation.</summary>
    public static float[] StationaryDistribution(MathBlockMatrix transition, int iterations)
    {
        ArgumentNullException.ThrowIfNull(transition);
        var distribution = MathBlockCollectionPrimitives.Repeat(
            1f / transition.Rows,
            transition.Rows);
        for (var iteration = 0; iteration < iterations; iteration++)
        {
            var next = new float[transition.Rows];
            for (var row = 0; row < transition.Rows; row++)
                for (var column = 0; column < transition.Columns; column++)
                    next[column] += distribution[row] * transition[row, column];
            distribution = next;
        }

        return distribution;
    }
}
