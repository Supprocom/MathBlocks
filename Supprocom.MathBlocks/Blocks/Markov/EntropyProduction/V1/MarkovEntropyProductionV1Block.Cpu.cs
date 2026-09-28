
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>markov.entropy-production@1</c> mathematical operation.</summary>
    public static double EntropyProduction(MathBlockMatrix transition, IReadOnlyList<double> stationary)
    {
        ArgumentNullException.ThrowIfNull(stationary);
        ArgumentNullException.ThrowIfNull(transition);
        var result = 0d;
        for (var row = 0; row < transition.Rows; row++)
        {
            for (var column = 0; column < transition.Columns; column++)
            {
                var forward = stationary[row] * transition[row, column];
                var reverse = stationary[column] * transition[column, row];
                if (forward > 0d && reverse == 0d)
                    return Math.PositiveInfinity;
                if (forward > 0d && reverse > 0d)
                    result += forward * MathBlockScalar.NaturalLogarithm(forward / reverse);
            }
        }

        return result;
    }
}
