
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] ShapleyValues(IReadOnlyList<double> coalitionValues)
    {
        var playerCount = Math.FloorLog2((uint)coalitionValues.Count);
        var result = new double[playerCount];
        var denominator = MathBlockProbability.Factorial(playerCount);
        for (var player = 0; player < playerCount; player++)
        {
            for (var coalition = 0; coalition < coalitionValues.Count; coalition++)
            {
                if ((coalition & (1 << player)) != 0)
                    continue;
                var size = Math.PopulationCount((uint)coalition);
                var weight = MathBlockProbability.Factorial(size) * MathBlockProbability.Factorial(playerCount - size - 1) / denominator;
                result[player] += weight * (coalitionValues[coalition | (1 << player)] - coalitionValues[coalition]);
            }
        }

        return result;
    }
}
